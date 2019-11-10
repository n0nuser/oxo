#!/bin/bash
#QUEDA POR HACER f(Estadisticas) Y f(Configuracion)


ComprobarConf() {
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

comprobarTablero() {
  echo "Entra en la función"
  # Comprueba el primero con el segundo y el segundo con el tercero
  if [ "${POSICION[0]}" = "${POSICION[4]}" ] && [ "${POSICION[4]}" = "${POSICION[8]}" ]; then
    COMPROBAR=1
    echo "Primera diagonal"
    return 1
  elif [ "${POSICION[2]}" = "${POSICION[4]}" ] && [ "${POSICION[4]}" = "${POSICION[6]}" ]; then
    COMPROBAR=1
    echo "Segunda diagonal"
    return 1
  fi
  for (($ i = 0; i < 3; i+3 )); do
    if [ "${POSICION[$i]}" = "${POSICION[$(($i + 1))]}" ] && [ "${POSICION[$(($i + 1))]}" = "${POSICION[$(($i + 2))]}" ]; then
      COMPROBAR=1
      echo "Línea"
      return 1
    fi
  done
  for (($ i = 0; i < 3; i++ )); do
    if [ "${POSICION[$i]}" = "${POSICION[$(($i + 3))]}" ] && [ "${POSICION[$(($i + 3))]}" = "${POSICION[$(($i + 6))]}" ]; then
    COMPROBAR=1
    echo "Columna"
    fi
  done
  
  echo "Nada. Se sigue jugando"
  COMPROBAR=0
  return 0
}

# HUMANO
comprobarFichaHumano(){
  AUX=$1
  AUX=$(($AUX - 1))
  if [ $AUX -ge 0 ] && [ $AUX -lt 9 ]; then
    if [ "${POSICION[$AUX]}" != "*" ]; then
      return 1
    fi
  else
    return 1
  fi
  echo "$FICHAHUMANO"
  return 0
}

comprobarFichaHumanoNew(){
  OLD=$1
  NEW=$2
  # Posición antigua
  if [ $OLD >= 0 ] && [ $OLD < 9 ]; then
    if [ '$POSICION[$(($OLD - 1))]' != '$FICHAHUMANO' ]; then
      return 1
    fi
  # Posición nueva
  elif [ $NEW >= 0 ] && [ $NEW < 9 ]; then
    if [ '$POSICION[$(($NEW - 1))]' != '*' ]; then
      return 1
    fi
  else
    return 1
  fi
  POSICION[$(($OLD - 1))]="*"
  POSICION[$(($NEW - 1))]="$FICHAHUMANO"
  return 0
}

turnoHumano(){
  #CAMBIARLO PARA OTRO DIA
  echo -e "\e[1;4mTURNO HUMANO\e[0m\n\n"
  if [ $CONTADORHUMANO -le 3 ]; then
    read -p "Inserta posición de $FICHAHUMANO: " POS_HUM_NEW
    CPB_FCH_HUM=$(comprobarFichaHumano "$POS_HUM_NEW")
    while [ $? -eq 1 ]
    do
      read -p "Inserta posición de $FICHAHUMANO: " POS_HUM_NEW
      CPB_FCH_HUM=$(comprobarFichaHumano "$POS_HUM_NEW")
    done
    POSICION[$(($POS_HUM_NEW - 1))]="$CPB_FCH_HUM"
  #TODO ESTO DE ARRIBA ESTÁ PERFECTO
  #AQUÍ YA SE HAN PUESTO LAS 3 FICHAS
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
}

# ORDENADOR
comprobarFichaPC(){
  # Aleatorio entre 0 - ... - 8
  POS_PC_NEW=$(( $RANDOM % 9 ))
  while [ ${POSICION[$POS_PC_NEW]} != '*' ]
  do
    POS_PC_NEW=$(( $RANDOM % 9))
  done
  # Va guardando las posiciones de las fichas en un array
  # Así nos ahorramos coste computacional después
  POSICIONES_FICHAS_PC[$(($CONTADORPC - 1))]=$POS_PC_NEW
  return $POS_PC_NEW
}

comprobarFichaPCNew(){
  # Aleatorio entre 0 - 1 - 2
  POS_RAND=$(( $RANDOM % 3 ))
  POS_PC_OLD=$POSICIONES_FICHAS_PC[$POS_RAND]
  POS_PC_NEW=$(( $RANDOM % 9 ))
  while [ '$POSICION[$POS_PC_NEW]' != '*' ]
  do
    POS_PC_NEW=$(( $RANDOM % 9 ))
  done
  POSICIONES_FICHAS_PC[$POS_RAND]=$POS_PC_NEW
  POSICION_PC=$POSICIONES_FICHAS_PC[$POS_RAND]
}

turnoPC(){
  echo -e "\e[1;4mTURNO PC\e[0m\n\n"
  #ANTES DE CUMPLIR 3 MOVS.
  sleep 4
  if [ $CONTADORPC -le 3 ]; then
    comprobarFichaPC
    POSICION[$?]="$FICHAPC"
  else
    comprobarFichaPCNew
  fi

}

Configuracion(){
  echo -e "\n"
  cat $FILE
  echo -e "\n"
}

Jugar(){
  clear
  echo -e "\nEl tablero es de la siguiente forma:"
  echo -e "\n\n\t 1 | 2 | 3 "
  echo -e "\t===·===·==="
  echo -e "\t 4 | 5 | 6 "
  echo -e "\t===·===·==="
  echo -e "\t 7 | 8 | 9 "

  sleep 5
  clear

  declare -a POSICION
  for (( i = 0; i < 9; i++ )); do
    POSICION[$i]="*"
  done
  declare -a FICHA=('O' 'X')
  declare -a POSICIONES_FICHAS_PC
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

  COMPROBAR=0
  while [ COMPROBAR != 1 ]
  do
    comprobarTablero
    echo COMPROBAR
    clear

    echo -e "\n\n\t| ${POSICION[0]} | ${POSICION[1]} | ${POSICION[2]} |\n\t === === ===\n\t| ${POSICION[3]} | ${POSICION[4]} | ${POSICION[5]} |\n\t === === ===\n\t| ${POSICION[6]} | ${POSICION[7]} | ${POSICION[8]} |\n\n"
    CONTADORHUMANO=1
    CONTADORPC=1

    echo "Valor de comprobarTablero: $COMPROBAR"
    if [ $COMIENZO -eq 1 ]; then
      turnoHumano
      CONTADORHUMANO=$(($CONTADORHUMANO + 1))
      COMIENZO=2

      comprobarTablero
      echo "Valor de comprobarTablero: $COMPROBAR"

    elif [ $COMIENZO -eq 2 ]; then
      turnoPC
      CONTADORPC=$(($CONTADORPC + 1))
      COMIENZO=1

      comprobarTablero
      echo "Valor de comprobarTablero: $COMPROBAR"

    fi
    echo -e "COMIENZO VALE $COMIENZO\nSi vale 1 significa que acaba de salir del turno pc, al revés y sale del turno humano."
  done
}

Estadisticas(){
  echo
}

Menu(){
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
    C | c)
      Configuracion
    ;;
    J | j)
      Jugar
    ;;
    E | e)
      Estadisticas
    ;;
    S | s)
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

if [ $1 = "-g" ];then
  echo -e "Pablo Jesus Gonzalez Rubio"
  echo -e "Francisco Javier Gallego Lahera"
  exit
fi
ComprobarConf
# DESPUÉS DE JUGAR VUELVE AQUÍ
clear
Menu
