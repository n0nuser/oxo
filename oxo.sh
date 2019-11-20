ComprobarConf() {
  FILE="oxo.cfg"
  # Verificar si el fichero existe
  # No haría falta si no existiera la opción de eliminar el archivo mientras se juega
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
  touch
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

turnoHumano(){
  echo -e "  \e[1;4;33mTURNO HUMANO\e[0m\n\n"
  if [ $CONTADORHUMANO -le 3 ]; then
    read -p "  Inserta posición de ficha '$FICHAHUMANO': " POS_HUM_NEW
    while ! [[ $POS_HUM_NEW =~ ^-?[1-9]+$ ]];do
      read -p "  Inserta posición de ficha '$FICHAHUMANO': " POS_HUM_NEW
    done
    CPB_FCH_HUM=$(comprobarFichaHumano "$POS_HUM_NEW")
    while [ $? -eq 1 ]
    do
      read -p "  Inserta posición de ficha '$FICHAHUMANO': " POS_HUM_NEW
      CPB_FCH_HUM=$(comprobarFichaHumano "$POS_HUM_NEW")
    done
    POSICION[$((POS_HUM_NEW-1))]="$CPB_FCH_HUM"
    INTERCAMBIO_MOVIMIENTOS_FILE[$CONTADORMOVIMIENTOS]="$COMIENZO.0.$((POS_HUM_NEW))"
  #AQUÍ YA SE HAN PUESTO LAS 3 FICHAS
  else
    # POSICIÓN ANTIGUA
    read -p "  Inserta posición ficha a mover: " POS_HUM_OLD
    while ! [[ $POS_HUM_OLD =~ ^-?[1-9]+$ ]];do
      read -p "  Inserta posición ficha a mover: " POS_HUM_OLD
    done
    comprobarFichaHumanoOld $POS_HUM_OLD
    while [ $? -eq 1 ]
    do
      read -p "  Inserta posición ficha a mover: " POS_HUM_OLD
      while ! [[ $POS_HUM_OLD =~ ^-?[1-9]+$ ]];do
        read -p "  Inserta posición ficha a mover: " POS_HUM_OLD
      done
      comprobarFichaHumanoOld $POS_HUM_OLD
    done
    # POSICIÓN NUEVA
    read -p "  Inserta nueva posición de ficha: " POS_HUM_NEW
    while ! [[ $POS_HUM_NEW =~ ^-?[1-9]+$ ]];do
      read -p "  Inserta nueva posición de ficha: " POS_HUM_NEW
    done
    comprobarFichaHumano $POS_HUM_NEW
    while [ $? -eq 1 ]
    do
      read -p "  Inserta nueva posición de ficha: " POS_HUM_NEW
      while ! [[ $POS_HUM_NEW =~ ^-?[1-9]+$ ]];do
        read -p "  Inserta nueva posición de ficha: " POS_HUM_NEW
      done
      comprobarFichaHumano $POS_HUM_NEW
    done
    POSICION[$((POS_HUM_OLD-1))]="*"
    POSICION[$((POS_HUM_NEW-1))]="$FICHAHUMANO"
    INTERCAMBIO_MOVIMIENTOS_FILE[$CONTADORMOVIMIENTOS]="$COMIENZO.$((POS_HUM_OLD)).$((POS_HUM_NEW))"
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
  if [[ $FICHACENTRAL -eq 1  && $POS_PC_OLD -eq 4 ]]; then
      while [ $POS_PC_OLD -eq 4 ]
      do
        POS_RAND=$(( $RANDOM % 3 ))
        POS_PC_OLD=${POSICIONES_FICHAS_PC[$POS_RAND]}
      done
      POS_PC_OLD=${POSICIONES_FICHAS_PC[$POS_RAND]}
  fi

  # POSICIÓN NUEVA
  POS_PC_NEW=$(( $RANDOM % 9 ))
  while [ "${POSICION[$POS_PC_NEW]}" != "*" ]
  do
    POS_PC_NEW=$(( $RANDOM % 9 ))
  done
  # Actualiza los valores de las posiciones entre las que elige el pc (antiguas)
  POSICIONES_FICHAS_PC[$POS_RAND]=$POS_PC_NEW
}

turnoPC(){
  echo -e "  \e[1;4;33mTURNO PC\e[0m\n\n"
  #ANTES DE CUMPLIR 3 MOVS.
  sleep 1.5
  if [ $CONTADORPC -le 3 ]; then
    comprobarFichaPC
    POSICION[$?]="$FICHAPC"
    INTERCAMBIO_MOVIMIENTOS_FILE[$CONTADORMOVIMIENTOS]="$COMIENZO.0.$((POS_PC_NEW))"
    #DESPUÉS DE CUMPLIR 3 MOVS.
  else
    comprobarFichaPCNew
    POSICION[$((POS_PC_OLD))]="*"
    POSICION[$((POS_PC_NEW))]="$FICHAPC"
    INTERCAMBIO_MOVIMIENTOS_FILE[$CONTADORMOVIMIENTOS]="$COMIENZO.$((POS_PC_OLD)).$((POS_PC_NEW))"
    return 0
  fi
}

Configuracion(){
  #ASIGNA A LOS VALORES FINALES LOS ANTIGUOS POR SI NO HAY CAMBIOS
  COMIENZONEW=$COMIENZO
  FICHACENTRALNEW=$FICHACENTRAL
  ESTADISTICASNEW=$ESTADISTICAS
  clear
  echo -e "\n\e[1;33m  ARCHIVO  DE\n CONFIGURACIÓN\n =============\e[0m\n" ; cat $FILE
  echo -e "\n \e[1;4;33mMENÚ\e[0m\n\n 1) COMIENZO\n 2) FICHACENTRAL\n 3) RUTA ESTADISTICAS\n 0) SALIR\n"
  read -p " Elija una opción >> " OPT_CONF
  while [ $OPT_CONF -ne 1 ] && [ $OPT_CONF -ne 2 ] && [ $OPT_CONF -ne 3 ] && [ $OPT_CONF -ne 0 ] && [ "$OPT_CONF" = "" ]
  do
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
        while ! [[ $COMIENZONEW =~ ^-?[1-3]+$ ]];do
          read -p "Introduce valor nuevo para COMIENZO: " COMIENZONEW
        done
      ;;
      2)
        echo -e "\n - Si tiene valor 1, la ficha central no se puede mover."
        echo -e " - Si vale 2, la ficha central se puede mover.\n"
        read -p "Introduce valor nuevo para FICHACENTRAL: " FICHACENTRALNEW
        while ! [[ $FICHACENTRALNEW =~ ^-?[1-2]+$ ]];do
          read -p "Introduce valor nuevo para FICHACENTRAL: " FICHACENTRALNEW
        done

      ;;
      3)
        read -p "Introduce ruta nueva para ESTADISTICAS: " ESTADISTICASNEW
        touch $ESTADISTICASNEW
        while [ $? -ne 0 ];do
          echo "La ruta no se puede establecer."
          read -p "Introduce ruta nueva para ESTADISTICAS: " ESTADISTICASNEW
          touch $ESTADISTICASNEW
        done
      ;;
      0)
        return 0
      ;;
      *)
        echo " Opción ERRÓNEA."
        sleep 1
        configuración
      ;;
    esac
    echo "COMIENZO=$COMIENZONEW" > oxo.cfg
    echo "FICHACENTRAL=$FICHACENTRALNEW" >> oxo.cfg
    echo "ESTADISTICAS=$ESTADISTICASNEW" >> oxo.cfg
    ComprobarConf
    clear
    echo -e "\n\e[1;33m  ARCHIVO  DE\n CONFIGURACIÓN\n =============\e[0m\n" ; cat $FILE
    echo -e "\n \e[1;4;33mMENÚ\e[0m\n\n 1) COMIENZO\n 2) FICHACENTRAL\n 3) RUTA ESTADISTICAS\n 0) SALIR"
    read -p " Elija una opción >> " OPT_CONF
    while [ $OPT_CONF -ne 1 ] && [ $OPT_CONF -ne 2 ] && [ $OPT_CONF -ne 3 ] && [ $OPT_CONF -ne 0 ]
    do
      echo -e "\n\nNo se ha introducido una opción válida.\n"
      read -p " Elija una opción >> " OPT_CONF
    done
  done
  return 0
}

Jugar(){
  clear
  # VARIABLES
  ###########
  # ARRAY UTILIZADO PARA ALMACENAR LAS POSICIONES DE LAS X y O
  declare -a POSICION
  for (( i = 0; i < 9; i++ )); do
    POSICION[$i]="*"
  done
  # ARRAY PARA ASIGNAR X ó O A HUMANO O PC
  declare -a FICHA=("O" "X")
  # ARRAY PARA GUARDAR POSICIONES DE LAS FICHAS PC
  # ASÍ SE AHORRA COSTE COMPUTACIONAL AL AHORRARSE EL RAND Y LA COMPROBACIÓN
  declare -a POSICIONES_FICHAS_PC
  # ARRAY PARA GUARDAR EN POSICIONES LA SECUENCIA DE MOVIMIENTOS
  # EN CADA POSICIÓN VA: "1.5.3" "2.2.7" ...
  declare -a INTERCAMBIO_MOVIMIENTOS_FILE
  # VARIABLE PARA
  MOVIMIENTOS=0
  # VARIABLE PARA VERIFICAR GANADOR
  GANADOR=0
  # VARIABLE PARA VER CUANTOS MOVIMIENTOS LLEVA CADA JUGADOR
  CONTADORHUMANO=1 ; CONTADORPC=1
  # VARIABLE PARA TERMINAR LA PARTIDA SI == 1
  TERMINAR=0
  # VARIABLE PARA EMPEZAR A CONTAR CUANDO SE HAN COLOCADO YA LAS 3 FICHAS
  CONTADORMOVIMIENTOS=0

  #ASIGNA A COMIENZO UN VALOR ALEATORIO ENTRE 1 Y 2
  if [ $COMIENZO -eq 3 ]; then
    COMIENZO=$(( $RANDOM % 2 + 1  ))
  fi
  COMIENZOORIGINAL=$COMIENZO
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
    echo -e "\n  Fecha de juego: $(date +%d-%m-%y)\n\n  Comienzo partida: $TIME1 segundos"
    echo -e "\n\n     \e[1;4;33mTABLERO\e[0m   \t\t\e[1;4;33mORDEN CASILLAS\e[0m\n\n  \e[1;33m|\e[0m ${POSICION[0]} \e[1;33m|\e[0m ${POSICION[1]} \e[1;33m|\e[0m ${POSICION[2]} \e[1;33m|\e[0m\t\t   1 | 2 | 3 \n   === === ===\t\t  ===·===·===\n  \e[1;33m|\e[0m ${POSICION[3]} \e[1;33m|\e[0m ${POSICION[4]} \e[1;33m|\e[0m ${POSICION[5]} \e[1;33m|\e[0m\t\t   4 | 5 | 6 \n   === === ===\t\t  ===·===·=== \n  \e[1;33m|\e[0m ${POSICION[6]} \e[1;33m|\e[0m ${POSICION[7]} \e[1;33m|\e[0m ${POSICION[8]} \e[1;33m|\e[0m\t\t   7 | 8 | 9 \n\n"
    echo -e "  Movimientos del jugador: $((CONTADORHUMANO-1))\n\n  Movimientos del ordenador: $((CONTADORPC-1))\n\n"
    # TURNO HUMANO
    if [ $COMIENZO -eq 1 ]; then
      turnoHumano
      CONTADORMOVIMIENTOS=$((CONTADORMOVIMIENTOS+1))
      MOVIMIENTOS=$((MOVIMIENTOS+1))
      CONTADORHUMANO=$((CONTADORHUMANO+1))
      COMIENZO=2
      if [ $CONTADORHUMANO -ge 3 ]; then
        comprobarTablero
        if [ $? -eq 1 ]; then clear; echo -e "\n\n\t| ${POSICION[0]} | ${POSICION[1]} | ${POSICION[2]} |\n\t === === ===\n\t| ${POSICION[3]} | ${POSICION[4]} | ${POSICION[5]} |\n\t === === ===\n\t| ${POSICION[6]} | ${POSICION[7]} | ${POSICION[8]} |\n\n" ;  echo -e " \e[1;5;33m¡HAS GANADO! 🏆\e[0m \n"; GANADOR=1 ; TERMINAR=1 ; for i in ${INTERCAMBIO_MOVIMIENTOS_FILE[@]}; do SEQ_POS+="$i:"; done ; MostrarEstadisticas ; exit; fi
      fi
    # TURNO PC
    elif [ $COMIENZO -eq 2 ]; then
      turnoPC
      CONTADORMOVIMIENTOS=$((CONTADORMOVIMIENTOS+1))
      MOVIMIENTOS=$((MOVIMIENTOS+1))
      CONTADORPC=$((CONTADORPC+1))
      COMIENZO=1
      if [ $CONTADORPC -ge 3 ]; then
        comprobarTablero
        if [ $? -eq 1 ]; then clear; echo -e "\n\n\t| ${POSICION[0]} | ${POSICION[1]} | ${POSICION[2]} |\n\t === === ===\n\t| ${POSICION[3]} | ${POSICION[4]} | ${POSICION[5]} |\n\t === === ===\n\t| ${POSICION[6]} | ${POSICION[7]} | ${POSICION[8]} |\n\n" ; echo -e " \e[1;5;33m¡HAS PERDIDO! 😞\e[0m \n" ; GANADOR=2 ; TERMINAR=1 ; for i in ${INTERCAMBIO_MOVIMIENTOS_FILE[@]}; do SEQ_POS+="$i:"; done ; MostrarEstadisticas ; exit; fi
      fi
    fi
  done
}

Estadisticas(){
  if [ ! -f $ESTADISTICAS ];then
    echo "No existe el fichero de estadisticas indicado en el archivo de configuración."
    return 1
  elif [ $(wc -l "$ESTADISTICAS" | cut -b 1) -eq 0 ];then
    echo "El archivo está vacío ya que no se ha jugado ninguna partida todavía."
  fi
  # LEER DATOS DEL ARCHIVO *.log
  MEDIA_TIEMPO=0
  CONTADOR_MEDIA=1
  TOTAL_TIEMPO=0
  PARTIDA_MAS_LARGA=0
  PARTIDA_MAS_CORTA=999999999999999
  PARTIDA_MAS_MOVS=0
  PARTIDA_MENOS_MOVS=999999999999999
  TOTAL_CASILLA_MEDIO=0
  CASILLA_MEDIO=0
  TOTAL_MOVS=0
  while IFS="|" read PID_FILE FECHA_FILE COMIENZO_FILE CENTRAL_FILE GANADOR_FILE TIME_FILE MOVS_FILE SEQ_FILE
  do
    i=1
    CONTADOR_MEDIA=$((CONTADOR_MEDIA+1))
    MEDIA_TIEMPO=$((MEDIA_TIEMPO+TIME_FILE))
    TOTAL_MOVS=$((TOTAL_MOVS+MOVS_FILE))
    CADENA=$(echo "$SEQ_FILE" | tr -cd ": 5")
    if [ $PARTIDA_MAS_LARGA -lt $TIME_FILE ];then PARTIDA_MAS_LARGA=$TIME_FILE; fi
    if [ $PARTIDA_MAS_CORTA -gt $TIME_FILE ];then PARTIDA_MAS_CORTA=$TIME_FILE; fi
    if [ $PARTIDA_MAS_MOVS -lt $MOVS_FILE ];then PARTIDA_MAS_MOVS=$MOVS_FILE; fi
    if [ $PARTIDA_MENOS_MOVS -gt $MOVS_FILE ];then
      CASILLA_MEDIO=0
      FLAG=1
      PARTIDA_MENOS_MOVS=$MOVS_FILE

      # NUMERO VECES CASILLA MEDIO EN PARTIDA MÁS CORTA (MOVS)
      while [ $i -ne ${#CADENA} ]; do
        CHAR=$(echo $CADENA | cut -b $i)
        # AQUÍ ENCUENTRA LA SEGUNDA FICHA
        if [[ "$CHAR" = "5" && $FLAG -eq 0 ]];then FLAG=1
        # AQUÍ LA PRIMERA
      elif [[ "$CHAR" = "5" && $FLAG -eq 1 ]];then FLAG=0; fi
        if [ $FLAG -eq 0 ];then CASILLA_MEDIO=$((CASILLA_MEDIO+1)); fi
        i=$((i+1))
      done
    fi
    # MOVIMIENTOS TOTALES EN CASILLA DEL MEDIO
    i=1; FLAG=1
    echo -e "\n\n$CADENA"
    while [ $i -ne ${#CADENA} ]; do
      CHAR=$(echo $CADENA | cut -b $i)
      if [[ "$CHAR" = "5" && $FLAG -eq 0 ]];then FLAG=1
    elif [[ "$CHAR" = "5" && $FLAG -eq 1 ]];then FLAG=0; fi
      if [ $FLAG -eq 0 ];then TOTAL_CASILLA_MEDIO=$((TOTAL_CASILLA_MEDIO+1)); fi
      echo "Pos $i || TCM = $TOTAL_CASILLA_MEDIO"
      i=$((i+1))
    done
  done < $ESTADISTICAS
  TOTAL_TIEMPO=$MEDIA_TIEMPO
  MEDIA_TIEMPO=$((MEDIA_TIEMPO/CONTADOR_MEDIA))
  # GENERAL
  clear
  echo -e "\n \e[1;4mESTADÍSTICAS\e[0m\n"
  echo -e "\n # \e[1;33mNº PARTIDAS JUGADAS:\e[0m $(wc -l "$ESTADISTICAS" | cut -b 1)";
  echo -e "\n # \e[1;33mNº TOTAL MOVIMIENTOS:\e[0m $TOTAL_MOVS";
  if [ $MEDIA_TIEMPO -gt 60 ];then
    echo -e "\n # \e[1;33mMEDIA TIEMPO TOTAL JUGADO:\e[0m $(($MEDIA_TIEMPO/60)) minuto(s) y $(($MEDIA_TIEMPO%60)) segundos"
  else
    echo -e "\n # \e[1;33mMEDIA TIEMPO TOTAL JUGADO:\e[0m $MEDIA_TIEMPO segundos"
  fi
  if [ $TOTAL_TIEMPO -gt 60 ];then
    echo -e "\n # \e[1;33mTIEMPO JUGADO TOTAL:\e[0m $(($TOTAL_TIEMPO/60)) minuto(s) y $(($TOTAL_TIEMPO%60)) segundos"
  else
    echo -e "\n # \e[1;33mTIEMPO JUGADO TOTAL:\e[0m $TOTAL_TIEMPO segundos"
  fi

  # JUGADAS ESPECIALES
  echo -e "\n\n # \e[1;33mPARTIDA MÁS CORTA:\e[0m $PARTIDA_MAS_CORTA segundos"
  echo -e "\n # \e[1;33mPARTIDA MÁS LARGA:\e[0m $PARTIDA_MAS_LARGA segundos"
  echo -e "\n # \e[1;33mPARTIDA CON MÁS MOVIMIENTOS:\e[0m $PARTIDA_MAS_MOVS movimientos"
  echo -e "\n # \e[1;33mPARTIDA CON MENOS MOVIMIENTOS:\e[0m $PARTIDA_MENOS_MOVS movimientos"
  echo -e "\n # \e[1;33mNº VECES LA CASILLA CENTRAL HA SIDO OCUPADA EN LA PARTIDA MÁS CORTA (TIEMPO)\n\n   RESPECTO AL TOTAL:\e[0m $(($CASILLA_MEDIO)) VS $(($TOTAL_CASILLA_MEDIO))"
}

MostrarEstadisticas(){
  #PID
  FECHA=$(date +%d-%m-%y)
  #COMIENZO
  #FICHACENTRAL
  #GANADOR
  TIME2=$(date +%s)
  TIME=$((TIME2 - TIME1))
  #MOVIMIENTOS (num movs)
  #SECUENCIA JUGADAS → ${SEQ_POS%?}

  echo -e "\n \e[1;4;33mDATOS\e[0m"
  echo -e "\n \e[1;33mPARTIDA                  :\e[0m $PID"
  echo -e "\n \e[1;33mFECHA                    :\e[0m $FECHA"
  if [ $COMIENZOORIGINAL -eq 1 ];then
    echo -e "\n \e[1;33mCOMIENZO                 :\e[0m Comienzas tú"
  else
    echo -e "\n \e[1;33mCOMIENZO                 :\e[0m Comienza el PC"
  fi
  if [ $FICHACENTRAL -eq 1 ];then
    echo -e "\n \e[1;33mFICHA CENTRAL            :\e[0m La ficha central no se puede mover"
  else
    echo -e "\n \e[1;33mFICHA CENTRAL            :\e[0m La ficha central se puede mover"
  fi
  if [ $GANADOR -eq 1 ];then
    echo -e "\n \e[1;33mGANADOR                  :\e[0m Has ganado"
  else
    echo -e "\n \e[1;33mGANADOR                  :\e[0m Ha ganado el PC"
  fi
  echo -e "\n \e[1;33mDURACIÓN PARTIDA         :\e[0m $TIME segundos"
  echo -e "\n \e[1;33mNº MOVIMIENTOS TOTALES   :\e[0m $MOVIMIENTOS"
  echo -e "\n \e[1;33mNº MOVIMIENTOS JUGADOR   :\e[0m $((CONTADORHUMANO-1))"
  echo -e "\n \e[1;33mMOVIMIENTOS REALIZADOS   :\e[0m ${SEQ_POS%?}\n"
  echo "$PID|$FECHA|$COMIENZOORIGINAL|$FICHACENTRAL|$GANADOR|$TIME|$MOVIMIENTOS|${SEQ_POS%?}" >> $ESTADISTICAS
}

Menu(){
  clear
  while [ "$OPCION" != "S" ]
  do
    VAR="*"
    echo -e "\e[1;5;33m  __     _  _     __  ";
    echo -e " /  \   ( \/ )   /  \ ";
    echo -e "(  O )   )  (   (  O )";
    echo -e " \__/   (_/\_)   \__/ \e[0m\n\n";
    echo -e " \e[1;33m== MENU ==\e[0m"
    echo -e "\n\e[1;33m C)\e[0m CONFIGURACIÓN"
    echo -e "\e[1;33m E)\e[0m ESTADÍSTICAS"
    echo -e "\e[1;33m J)\e[0m JUGAR"
    echo -e "\e[1;33m S)\e[0m SALIR\n"
    echo -en " \e[1;4mOXO\e[0m. Introduzca una opción >> "; read OPCION
    case $OPCION in
      C | c)
        Configuracion
        ;;
      J | j)
        PID=$$
        TIME1=$(date +%s)
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
        sleep 1
        clear
        Menu
        ;;
    esac
    echo
    while [ "$VAR" != "" ];
    do
      read -p "Introduzca INTRO para continuar >> " VAR
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
