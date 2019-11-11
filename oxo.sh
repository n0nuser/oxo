# PROBLEMAS AL COMPROBAR FICHA HUMANO NUEVA Y FICHA PC NUEVA

ComprobarConf() {
  FILE="oxo.cfg"
  # Verificar si el fichero existe
  # No haría falta si no existiera la opcion de eliminar el archivo mientras se juega
  # Pero es mejor así por si acaso
  if [ ! -f "$FILE" ]; then
      echo -e "\e[1;31mERROR\e[0m. El archivo $FILE no existe."
      exit;
  fi

  if [ $(wc -l "$FILE" | cut -b 1) -ne 3 ];then
    echo -e "\e[1;31mERROR\e[0m. El fichero $FILE no tiene los 3 campos necesarios (COMIENZO, FICHACENTRAL, ESTADISTICAS)."
    #Configuracion
    exit;
  fi

  # Recoger los datos del fichero
  while IFS="=" read DATO VALOR
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
# DIAGONALES
  if [ "${POSICION[0]}" = "${POSICION[4]}" ] && [ "${POSICION[4]}" = "${POSICION[8]}" ] && [ "${POSICION[0]}" != "*" ] && [ "${POSICION[4]}" != "*" ] && [ "${POSICION[8]}" != "*" ]; then
    return 1
  elif [ "${POSICION[2]}" = "${POSICION[4]}" ] && [ "${POSICION[4]}" = "${POSICION[6]}" ] && [ "${POSICION[2]}" != "*" ] && [ "${POSICION[4]}" != "*" ] && [ "${POSICION[6]}" != "*" ]; then
    return 1
  #FILAS
  elif [ "${POSICION[0]}" = "${POSICION[1]}" ] && [ "${POSICION[1]}" = "${POSICION[2]}" ] && [ "${POSICION[0]}" != "*" ] && [ "${POSICION[1]}" != "*" ] && [ "${POSICION[2]}" != "*" ]; then
    return 1
  elif [ "${POSICION[3]}" = "${POSICION[4]}" ] && [ "${POSICION[4]}" = "${POSICION[5]}" ] && [ "${POSICION[3]}" != "*" ] && [ "${POSICION[4]}" != "*" ] && [ "${POSICION[5]}" != "*" ]; then
    return 1
  elif [ "${POSICION[6]}" = "${POSICION[7]}" ] && [ "${POSICION[7]}" = "${POSICION[8]}" ] && [ "${POSICION[6]}" != "*" ] && [ "${POSICION[7]}" != "*" ] && [ "${POSICION[8]}" != "*" ]; then
    return 1
  #COLUMNAS
  elif [ "${POSICION[0]}" = "${POSICION[3]}" ] && [ "${POSICION[3]}" = "${POSICION[6]}" ] && [ "${POSICION[0]}" != "*" ] && [ "${POSICION[3]}" != "*" ] && [ "${POSICION[6]}" != "*" ]; then
    return 1;
  elif [ "${POSICION[1]}" = "${POSICION[4]}" ] && [ "${POSICION[4]}" = "${POSICION[7]}" ] && [ "${POSICION[1]}" != "*" ] && [ "${POSICION[4]}" != "*" ] && [ "${POSICION[7]}" != "*" ]; then
    return 1
  elif [ "${POSICION[2]}" = "${POSICION[5]}" ] && [ "${POSICION[5]}" = "${POSICION[8]}" ] && [ "${POSICION[2]}" != "*" ] && [ "${POSICION[5]}" != "*" ] && [ "${POSICION[8]}" != "*" ]; then
    return 1
  fi
  return 0
}

# HUMANO
comprobarFichaHumano(){
  AUX=$1
  AUX=$((AUX-1))
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

comprobarFichaHumanoOld(){
  OLD=$1
  TEMP=$((OLD-1))
  if [ $TEMP -ge 0 ] && [ $TEMP -lt 9 ]; then
    if [ "${POSICION[$TEMP]}" != "$FICHAHUMANO" ]; then
      return 1
    elif [ $TEMP -eq 4 ] && [ $FICHACENTRAL -eq 1 ];then
      return 1
    fi
  else
    return 1
  fi
  return 0
}

comprobarFichaHumanoNew(){
  NEW=$1
  TEMP2=$((NEW-1))
  if [ $TEMP2 -ge 0 ] && [ $TEMP2 -lt 9 ]; then
    if [ "${POSICION[$TEMP2]}" != "*" ]; then
      return 1
    else
      return 0
    fi
  else
    return 1
  fi
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
    POSICION[$((POS_HUM_NEW-1))]="$CPB_FCH_HUM"
  #TODO ESTO DE ARRIBA ESTÁ PERFECTO

  #AQUÍ YA SE HAN PUESTO LAS 3 FICHAS
  else
    # Intercambiar posiciones de ficha humano
    #echo "POSICIONES GUARDADAS DE FICHAS PC: "
    #echo -e "$((${POSICIONES_FICHAS_PC[0]}+1))"
    #echo -e "$((${POSICIONES_FICHAS_PC[1]}+1))"
    #echo -e "$((${POSICIONES_FICHAS_PC[2]}+1))"

    read -p "Inserta posición ficha a mover: " POS_HUM_OLD
    comprobarFichaHumanoOld $POS_HUM_OLD
    while [ $? -eq 1 ]
    do
      read -p "Inserta posición ficha a mover: " POS_HUM_OLD
      comprobarFichaHumanoOld $POS_HUM_OLD
    done


    read -p "Inserta nueva posición de ficha: " POS_HUM_NEW
    comprobarFichaHumanoNew $POS_HUM_NEW
    while [ $? -eq 1 ]
    do
      read -p "Inserta nueva posición de ficha: " POS_HUM_NEW
      comprobarFichaHumanoNew $POS_HUM_NEW
    done
    POSICION[$((POS_HUM_OLD-1))]="*"
    POSICION[$((POS_HUM_NEW-1))]="$FICHAHUMANO"
  fi
}

# ORDENADOR
comprobarFichaPC(){
  # Aleatorio entre 0 - ... - 8
  POS_PC_NEW=$(( $RANDOM % 9 ))
  while [ "${POSICION[$POS_PC_NEW]}" != "*" ]
  do
    POS_PC_NEW=$(( $RANDOM % 9))
  done
  # Va guardando las posiciones de las fichas en un array
  # Así nos ahorramos coste computacional después
  POSICIONES_FICHAS_PC[$((CONTADORPC-1))]=$POS_PC_NEW
  return $POS_PC_NEW
}


comprobarFichaPCNew(){
  # POSICIÓN ANTIGUA
  POS_RAND=$(( $RANDOM % 3 ))
  POS_PC_OLD=${POSICIONES_FICHAS_PC[$POS_RAND]}
  #echo "Posición antigua elegida por el PC: $((POS_PC_OLD+1))"
  #sleep 5

  # POSICIÓN NUEVA
  POS_PC_NEW=$(( $RANDOM % 9 ))
  #echo "Nueva posición elegida por el PC: $((POS_PC_NEW+1))"
  #sleep 5
  while [ "${POSICION[$POS_PC_NEW]}" != "*" ]
  do
    #sleep 5
    POS_PC_NEW=$(( $RANDOM % 9 ))
    #echo "Se acaba de elegir: $((POS_PC_NEW+1))"
    #echo "El valor de la posición elegida es: "${POSICION[$POS_PC_NEW]}""
    #sleep 5
  done
  # Actualiza los valores de las posiciones entre las que elige el pc (antiguas)
  POSICIONES_FICHAS_PC[$POS_RAND]=$POS_PC_NEW
}

turnoPC(){
  echo -e "\e[1;4mTURNO PC\e[0m\n\n"
  #ANTES DE CUMPLIR 3 MOVS.
  #sleep 4
  if [ $CONTADORPC -le 3 ]; then
    comprobarFichaPC
    POSICION[$?]="$FICHAPC"
  else
    comprobarFichaPCNew
    POSICION[$((POS_PC_OLD))]="*"
    POSICION[$((POS_PC_NEW))]="$FICHAPC"
  fi

}

Configuracion(){
  #ASIGNA A LOS VALORES FINALES LOS ANTIGUOS POR SI NO HAY CAMBIOS
  COMIENZONEW=$COMIENZO
  FICHACENTRALNEW=$FICHACENTRAL
  RUTAESTADISTICASNEW=$ESTADISTICAS
  clear ; echo -e "\n\e[1;33m  ARCHIVO  DE\n CONFIGURACIÓN\n =============\e[0m\n" ; cat $FILE
  echo -e "\n \e[1;4;33mMENÚ\e[0m\n\n 1) COMIENZO\n 2) FICHACENTRAL\n 3) RUTA ESTADISTICAS\n 0) SALIR"
  read -p " Elija una opción >> " OPT_CONF
  while [ $OPT_CONF -ne 1 ] && [ $OPT_CONF -ne 2 ] && [ $OPT_CONF -ne 3 ] && [ $OPT_CONF -ne 0 ]
  do
    echo -e "\n\nNo se ha introducido una opción válida.\n"
    read -p " Elija una opción >> " OPT_CONF
  done
  while [ $OPT_CONF -ne 0 ]
  do
    case $OPT_CONF in
      1)
        echo -e "\n - Si tiene valor 1 empieza el usuario."
        echo " - Si tiene valor 2 empieza el ordenador."
        echo -e " - Si tiene valor 3 se elige aleatoriamente entre el usuario y el ordenador.\n"
        read -p "Introduce valor nuevo para COMIENZO: " COMIENZONEW
      ;;
      2)
        echo -e "\n - Si tiene valor 1, la ficha central no se puede mover."
        echo -e " - Si vale 2, la ficha central se puede mover.\n"
        read -p "Introduce valor nuevo para FICHACENTRAL: " FICHACENTRALNEW
      ;;
      3)
        read -p "Introduce ruta nueva para ESTADISTICAS: " RUTAESTADISTICASNEW
      ;;
      0)
        return 0
      ;;
    esac
    echo "COMIENZO=$COMIENZONEW" > oxo.cfg
    echo "FICHACENTRAL=$FICHACENTRALNEW" >> oxo.cfg
    echo "ESTADISTICAS=$RUTAESTADISTICASNEW" >> oxo.cfg
    ComprobarConf
    clear ; echo -e "\n\e[1;33m  ARCHIVO  DE\n CONFIGURACIÓN\n =============\e[0m\n" ; cat $FILE
    echo -e "\n \e[1;4;33mMENÚ\e[0m\n\n 1) COMIENZO\n 2) FICHACENTRAL\n 3) RUTA ESTADISTICAS\n 0) SALIR"
    read -p " Elija una opción >> " OPT_CONF
    while [ $OPT_CONF -ne 1 ] && [ $OPT_CONF -ne 2 ] && [ $OPT_CONF -ne 3 ] && [ $OPT_CONF -ne 0 ]
    do
      echo -e "\n\nNo se ha introducido una opción válida.\n"
      read -p " Elija una opción >> " OPT_CONF
    done
  done
  clear
  return 0
}

Jugar(){
  clear
  echo -e "\nEl tablero es de la siguiente forma:"
  echo -e "\n\n\t 1 | 2 | 3 "
  echo -e "\t===·===·==="
  echo -e "\t 4 | 5 | 6 "
  echo -e "\t===·===·==="
  echo -e "\t 7 | 8 | 9 "

  #sleep 5
  #clear

  # VARIABLES
  declare -a POSICION
  for (( i = 0; i < 9; i++ )); do
    POSICION[$i]="*"
  done
  declare -a FICHA=("O" "X")
  declare -a POSICIONES_FICHAS_PC
  CONTADORHUMANO=1 ; CONTADORPC=1
  TERMINAR=0

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

  while [ TERMINAR != 1 ]
  do
    clear
    echo -e "\n\n\t| ${POSICION[0]} | ${POSICION[1]} | ${POSICION[2]} |\n\t === === ===\n\t| ${POSICION[3]} | ${POSICION[4]} | ${POSICION[5]} |\n\t === === ===\n\t| ${POSICION[6]} | ${POSICION[7]} | ${POSICION[8]} |\n\n"
    # TURNO HUMANO
    if [ $COMIENZO -eq 1 ]; then
      turnoHumano
      CONTADORHUMANO=$((CONTADORHUMANO+1))
      COMIENZO=2
      if [ $CONTADORHUMANO -ge 3 ]; then
        comprobarTablero
        VAR_PRUEBA=$((comprobarTablero))
        comprobarTablero
        if [ $? -eq 1 ]; then clear ; echo -e "\n\n\t| ${POSICION[0]} | ${POSICION[1]} | ${POSICION[2]} |\n\t === === ===\n\t| ${POSICION[3]} | ${POSICION[4]} | ${POSICION[5]} |\n\t === === ===\n\t| ${POSICION[6]} | ${POSICION[7]} | ${POSICION[8]} |\n\n" ;  echo -e "\e[1;5;33m¡HAS GANADO! 🏆\e[0m \n"; TERMINAR=1 ; exit ; fi
      fi
    # TURNO PC
    elif [ $COMIENZO -eq 2 ]; then
      turnoPC
      CONTADORPC=$((CONTADORPC+1))
      COMIENZO=1
      if [ $CONTADORPC -ge 3 ]; then
        comprobarTablero
        VAR_PRUEBA=$((comprobarTablero))
        comprobarTablero
        if [ $? -eq 1 ]; then clear ; echo -e "\n\n\t| ${POSICION[0]} | ${POSICION[1]} | ${POSICION[2]} |\n\t === === ===\n\t| ${POSICION[3]} | ${POSICION[4]} | ${POSICION[5]} |\n\t === === ===\n\t| ${POSICION[6]} | ${POSICION[7]} | ${POSICION[8]} |\n\n" ; echo -e "\e[1;5;33m¡HAS PERDIDO! 😞\e[0m \n" ; TERMINAR=1 ; exit ; fi
      fi
    fi
  done
}

Estadisticas(){
  echo
}

Menu(){
  clear
  echo -e "\e[1;5;33m  __     _  _     __  ";
  echo -e " /  \   ( \/ )   /  \ ";
  echo -e "(  O )   )  (   (  O )";
  echo -e " \__/   (_/\_)   \__/ \e[0m\n\n";
  echo -e " \e[1;33m== MENU ==\e[0m"
  echo -e "\n\e[1;33m C)\e[0m CONFIGURACIÓN"
  echo -e "\e[1;33m E)\e[0m ESTADÍSTICAS"
  echo -e "\e[1;33m J)\e[0m JUGAR"
  echo -e "\e[1;33m S)\e[0m SALIR\n"

  # Leer la opción del menú
  # -p Muestra el texto y pregunta sin meter salto de línea
  OPCION=A
  VAR_ESPERA=" "
  while [ "$OPCION" != "S"]
  do
    Menu
    echo -en " \e[1;4mOXO\e[0m. Introduzca una opción >> "; read OPCION
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
        #sleep 5
        clear
        Menu
        ;;
    esac
    while [ "$VAR" != "\n" ]; 
    do
      read -p "\nIntroduzca INTRO para continuar >>" VAR
    done
    clear
  done
}

if [ "$1" = "-g" ];then
  echo -e "Pablo Jesus Gonzalez Rubio"
  echo -e "Francisco Javier Gallego Lahera"
  exit
fi
ComprobarConf
Menu
