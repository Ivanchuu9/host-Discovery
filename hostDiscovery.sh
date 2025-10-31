#!/usr/bin/env bash
# Simple host discovery and port scan script
# Author: <ivanchuu9>
# Usage: ./hostDiscovery.sh IP/CIDR
#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

set -euo pipefail

function ctrl_c( ){
 	echo -e "\n\n${redColour} [ ! ] Saliendo...${endColour}\n"
	tput cnorm && exit 1
}

# Ctrl+C
trap ctrl_c SIGINT
tput civis

#HelpPanel Function
function helpPanel(){
	echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso: "${endColour}${purpleColour} $0 ${endColour}
	echo -e "\t${blueColour}-n) ${endColour}${grayColour} Network"${endColour}
	tput cnorm && exit 1
}

function hostDiscovery(){
  local network=$network
  local ports=(21 22 23 25 80 139 443 445 8080)
  
  echo -e "\n${yellowColour}[ + ]${endColour}${grayColour} Red a escanear: ${endColour}${purpleColour}$network${endColour}" 
  echo -e "\n${yellowColour}[*]${endColour}${grayColour} Escaneando red: ${endColour}${purpleColour}$network${endColour}${grayColour} ...${endColour}"

  # 1) Descubre hosts vivos y cárgalos en un array
  mapfile -t ips < <(nmap -sn -n "$network" -oG - | awk '/Up$/{print $2}') 

  echo -e "\n${yellowColour}[i]${endColour}${grayColour} Hosts vivos encontrados: ${endColour}${blueColour}${#ips[@]}${endColour}"
  
  if [ "${#ips[@]}" -eq 0 ]; then
    echo -e "\n${yellowColour}[i]${endColour}${grayColour} No se encontraron hosts vivos en ${purpleColour}$network${endColour}"
    tput cnorm
    return 0
  fi

  # 2) Escanear puertos en cada IP (limitando concurrencia)
  
  local max_jobs=64
  local running=0
  
  for ip in "${ips[@]}"; do
    echo -e "\n${yellowColour}[*]${endColour}${grayColour} Escaneando host: ${endColour}${purpleColour}$ip${endColour}" 
    for port in "${ports[@]}"; do
      (
        set +e
        if timeout 1 bash -c "echo > /dev/tcp/$ip/$port" 2>/dev/null; then
            echo -e "\n\t${yellowColour}[+] ${endColour}${grayColour}HOST: ${endColour}${purpleColour}$ip${endColour}${grayColour}: PORT [${endColour}${blueColour}$port${endColour}${grayColour}]${endColour}${greenColour} (OPEN)${endColour}"
        fi
      ) &

      ((running++))
      if (( running >= max_jobs )); then
        wait -n  # espera a que termine uno
        ((running--))
      fi
    done
  done

  echo -e "\n${yellowColour}[i]${endColour}${grayColour} Escaneo completado.${endColour}"
  wait


  tput cnorm
}


#Creamos parametros m y t, usamos variable arg, case abir caso, esac cerrar, if->fi
network=""

while getopts ":n:h" arg; do #GETOPTS que nos permita alternar entre una serie de funciones existentes
	case $arg in
	  n) network="$OPTARG";; #$OPTARG -> recibir parametro que estamos especificando
	  h) helpPanel;;
    :)  # opción con argumento faltante, p.ej. -m sin valor
        echo -e "\n${redColour}[ ! ] La opción ${turquoiseColour}-$OPTARG${endColour} requiere un valor.${endColour}" 
        helpPanel; exit 1 ;;
    \?) # opción desconocida
       echo -e "\n${redColour}[ ! ] Opción no válida: ${turquoiseColour}-$OPTARG${endColour}${endColour}" 
       helpPanel; exit 1 ;;
  esac
done 

# Regex: valida IPv4 con CIDR opcional, sin ceros a la izquierda
regex_ipv4_opt_cidr='^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\/(3[0-2]|[12]?[0-9]))?$'

if [ -n "$network" ]; then
  
  if [[ "$network" =~ $regex_ipv4_opt_cidr ]]; then
    hostDiscovery
  else
    echo -e "\n${redColour}[ ! ] Formato de IP/CIDR inválido: '${endColour}${turquoiseColour}${network}${endColour}${redColour}'${endColour}"
    helpPanel; exit 1
  fi
  
else 		
  echo -e "\n${redColour}[ ! ] La red no se puede escanear debido a los parametros introducidos ${endColour}"
	helpPanel; exit 1
fi
