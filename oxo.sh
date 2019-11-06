#!/bin/bash
#QUEDA POR HACER f(Estadisticas) Y f(Configuracion)

function Comprobar-g(){
  if [ "$2" = "-g" ];then
    echo -e "\e[35mPablo\e[0m Jesus Gonzalez Rubio"
    echo -e "Francisco Javier Gallego Lahera"
    return 1
  fi
}

function ComprobarConf() {
  FILE='oxo.cfg'
  # Verificar si el fichero existe
  # No haría falta si no existiera la opcion de eliminar el archivo mientras se juega
  # Pero es mejor así por si acaso
  if [ ! -f "$FILE" ]; then
      echo -e "\e[1;31mERROR\e[0m. El archivo $FILE no existe."
      exit;
  fi

  if [ $(wc -l "$FILE" | cut -b 1) != "3" ];then
    echo -e "\e[1;31mERROR\e[0m. El fichero $FILE no tiene los 3 campos necesarios (COMIENZO, FICHACENTRAL, ESTADISTICAS)."
    exit;
  fi

  # Recoger los datos del fichero
  while IFS='=' read DATO VALOR
  do
    # Nos garantizamos que aun cambiando la linea de orden, sigue funcionando
    if [ $DATO = "COMIENZO" ]; then
      COMIENZO=$VALOR
    elif [ $DATO = "FICHACENTRAL" ]; then
      FICHACENTRAL=$VALOR
    elif [ $DATO = "ESTADISTICAS" ]; then
      ESTADISTICAS=$VALOR
    fi
  done < $FILE

  if [ $COMIENZO != 1 ] && [ $COMIENZO != 2 ] && [ $COMIENZO != 3 ];then
    echo -e "\e[1;31mERROR\e[0m. No se ha introducido un valor correcto del COMIENZO (1,2 o 3)."
    exit;
  fi

  if [ $FICHACENTRAL != 1 ] && [ $FICHACENTRAL != 2 ];then
    echo -e "\e[1;31mERROR\e[0m. No se ha introducido un valor correcto de la FICHACENTRAL (1 o 2)."
    exit;
  fi
}

function comprobarTablero() {
  # Comprueba si el tablero está lleno
  # Comprueba el primero con el segundo y el segundo con el tercero
  if [ "POSICION[0]" != "*" ] && [ "POSICION[1]" != "*" ] && [ "POSICION[2]" != "*" ] && [ "POSICION[3]" != "*" ] && [ "POSICION[4]" != "*" ] && [ "POSICION[5]" != "*" ] && [ "POSICION[6]" != "*" ] && [ "POSICION[7]" != "*" ] && [ "POSICION[8]" != "*" ]; then
    if [ "POSICION[0]" = "POSICION[4]" ] && [ "POSICION[4]" = "POSICION[8]" ]; then
      return 1
    elif [ "POSICION[2]" = "POSICION[4]" ] && [ "POSICION[4]" = "POSICION[6]" ]; then
      return 1
    fi
    for (( i = 0; i < 2; i+3 )); do
      if [ "POSICION[$i]" = "POSICION[$i+1]" ] && [ "POSICION[$i+1]" = "POSICION[$i+2]" ]; then
        return 1
      fi
    done
    for (( i = 0; i < 2; i++ )); do
      if [ "POSICION[$i]" = "POSICION[$i+3]" ] && [ "POSICION[$i+3]" = "POSICION[$i+6]" ]; then
      return 1
      fi
    done
  fi
  return 0
}

# HUMANO
function comprobarFichaHumano(){
  AUX=$1
  if [ $AUX -ge 0 ] && [ $AUX -lt 9 ]; then
    while [ ${POSICION[$((AUX-1))]} != '*' ]
    do
      echo "Posición Ya Ocupada."
    done
    POSICION[$((AUX-1))]="$FICHAHUMANO"
  else
    echo "Posición NO Válida."
    return 1
  fi
}

function comprobarFichaHumanoNew(){
  OLD=$1
  NEW=$2
  # Posición antigua
  if [ $OLD >= 0 ] && [ $OLD < 9 ]; then
    if [ '$POSICION[$((OLD-1))]' != '$FICHAHUMANO' ]; then
      echo "No has elegido una de tus fichas."
      return 1
    fi
  # Posición nueva
  elif [ $NEW >= 0 ] && [ $NEW < 9 ]; then
    if [ '$POSICION[$((NEW-1))]' != '*' ]; then
      echo "Posición Ya Ocupada."
      return 1
    fi
    POSICION[$((OLD-1))]="*"
    POSICION[$((NEW-1))]="$FICHAHUMANO"
  else
    echo "Posición NO Válida."
    return 1
  fi
}

function turnoHumano(){
  #CAMBIARLO PARA OTRO DIA
  if [ $CONTADORHUMANO -le 3 ]; then
    read -p "Inserta posición de $FICHAHUMANO: " POS_HUM_NEW
    while [ $((comprobarFichaHumano $POS_HUM_NEW)) = "1" ]
    do
      read -p "Inserta posición de $FICHAHUMANO: " POS_HUM_NEW
    done
  else
    # Intercambiar posiciones de ficha humano
    read -p "Inserta posición ficha a mover: " POS_HUM_OLD
    read -p "Inserta nueva posición de ficha: " POS_HUM_NEW
    while [ $(comprobarFichaHumanoNew $POS_HUM_OLD $POS_HUM_NEW) -eq 1 ]
    do
      read -p "Inserta posición ficha a mover: " POS_HUM_OLD
      read -p "Inserta nueva posición de ficha: " POS_HUM_NEW
    done
  fi
  COMIENZO=2
}

# ORDENADOR
function comprobarFichaPC(){
  # Aleatorio entre 0 - ... - 8
  POS_PC_NEW=$(( $RANDOM % 9 ))
  while [ '$POSICION[$POS_PC_NEW]' != '*' ]
  do
    POS_PC_NEW=$(( $RANDOM % 9))
    # Va guardando las posiciones de la ficha del pc en un array
    # Así nos ahorramos coste computacional después
  done
  VALORES_FICHAS_PC[$((CONTADORPC-1))]=$POS_PC_NEW
  POSICION_PC=$VALORES_FICHAS_PC[$POS_RAND]
}

function comprobarFichaPCNew(){
  # Aleatorio entre 0 - 1 - 2
  POS_RAND=$(( $RANDOM % 3 ))
  POS_PC_OLD=$VALORES_FICHAS_PC[$POS_RAND]
  POS_PC_NEW=$(( $RANDOM % 9 ))
  while [ '$POSICION[$POS_PC_NEW]' != '*' ]
  do
    POS_PC_NEW=$(( $RANDOM % 9 ))
  done
  VALORES_FICHAS_PC[$POS_RAND]=$POS_PC_NEW
  POSICION_PC=$VALORES_FICHAS_PC[$POS_RAND]
}

function turnoPC(){
  #ANTES DE CUMPLIR 3 MOVS.
  sleep 3
  if [ CONTADORPC -le 3]; then
    comprobarFichaPC
  else
    comprobarFichaPCNew
  fi
  POSICION[$POSICION_PC]="$FICHAPC"

  COMIENZO=1
}

function Configuracion(){
  echo
}

function Jugar(){
  clear
  echo -e "\nEl tablero es de la siguiente forma:"
  echo -e "\n\n\t 1 | 2 | 3 "
  echo -e "\t===·===·==="
  echo -e "\t 4 | 5 | 6 "
  echo -e "\t===·===·==="
  echo -e "\t 7 | 8 | 9 "

  sleep 3
  clear

  for (( i = 0; i < 9; i++ )); do
    POSICION[$i]="*"
  done
  declare -a FICHA=('O' 'X')
  declare -a VALORES_FICHAS_PC
  #ASIGNA A COMIENZO UN VALOR ALEATORIO ENTRE 1 Y 2
  if [ $COMIENZO -eq 3 ]; then
    COMIENZO=$(( $RANDOM % 2 + 1  ))
  fi
  #ASIGNA LAS FICHAS A ORDENADOR Y HUMANO
  if [ $COMIENZO -eq 1 ];then
    FICHAHUMANO=${FICHA[1]}
    FICHAPC=${FICHA[0]}
  elif [ $COMIENZO -eq 2 ];then
    FICHAHUMANO=${FICHA[0]}
    FICHAPC=${FICHA[1]}
  fi

  #while [ comprobarTablero != 1 ]
  #do
    echo -e "\n\n\t| ${POSICION[0]} | ${POSICION[1]} | ${POSICION[2]} |\n\t === === ===\n\t| ${POSICION[3]} | ${POSICION[4]} | ${POSICION[5]} |\n\t === === ===\n\t| ${POSICION[6]} | ${POSICION[7]} | ${POSICION[8]} |\n\n"
    CONTADORHUMANO=1
    CONTADORPC=1
    if [ $COMIENZO -eq 3 ]; then
      COMIENZO=$(( $RANDOM % 2 + 1  ))
    elif [ $COMIENZO -eq 1 ]; then
      turnoHumano
      $((CONTADORHUMANO++))
    elif [ $COMIENZO -eq 2 ]; then
      turnoPC
      $((CONTADORPC++))
    fi

  #done
}

function Estadisticas(){
  echo
}

function Menu(){
  echo -e "\e[1;5;33m  __     _  _     __  ";
  echo -e " /  \   ( \/ )   /  \ ";
  echo -e "(  O )   )  (   (  O )";
  echo -e " \__/   (_/\_)   \__/ \e[0m\n\n";
  echo -e "\e[1;33m== MENU ==\e[0m"
  echo -e "\n\e[1;33m C)\e[0m CONFIGURACIÓN"
  echo -e "\e[1;33m E)\e[0m ESTADÍSTICAS"
  echo -e "\e[1;33m J)\e[0m JUGAR"
  echo -e "\e[1;33m S)\e[0m SALIR\n"
  # Leer la opción del menú
  # -p Muestra el texto y pregunta sin meter salto de línea
  echo -en "\e[1;4mOXO\e[0m. Introduzca una opción >> "; read OPCION
  case $OPCION in
    C)
      Configuracion
    ;;
    J)
      Jugar
    ;;
    E)
      Estadisticas
    ;;
    S)
      echo -e "\n\t\e[1;33mSaliendo\e[0m del programa...\n"
      exit;
    ;;
    *)
      echo -e "\n\nNo se ha introducido una opción válida.\n"
      sleep 5
      clear
      Menu
    ;;
  esac
}

Comprobar-g
ComprobarConf
# DESPUÉS DE JUGAR VUELVE AQUÍ
#clear
Menu
