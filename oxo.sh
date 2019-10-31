#!/bin/bash

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

  # Verifica que no hay saltos de línea en el archivo
  #if [ $(find -name "oxo.cfg" -printf '\n' | wc -l) -ge 1 ];then
    #echo -e "\e[1;31mERROR\e[0m. El fichero $FILE contiene una o más líneas en blanco."
    #exit
  #fi

  if [ $(wc -l "$FILE" | cut -b 1) != "3" ];then
    echo -e "\e[1;31mERROR\e[0m. El fichero $FILE no tiene los 3 campos necesarios (COMIENZO, FICHACENTRAL, ESTADISTICAS)."
    exit;
  fi

  # Recoger los datos del fichero
  i=0
  while IFS='=' read DATO VALOR
  do
    i=$(($i+1))
    # Se recoge unicamente el valor, el nombre se descarta
    # Aun asi, el nombre hay que guardarlo en dato, para que se separe bien
    if [ $i == 1 ];then
      COMIENZO=$VALOR
    fi
    if [ $i == 2 ];then
      FICHACENTRAL=$VALOR
    fi
    if [ $i == 3 ];then
      ESTADISTICAS=$VALOR
    fi
  done < $FILE

  #AQUÍ DA ERROR
  if [ $COMIENZO != 1 ] && [ $COMIENZO != 2 ] && [ $COMIENZO != 3 ];then
    echo -e "\e[1;31mERROR\e[0m. No se ha introducido un valor correcto del COMIENZO (1,2 o 3)."
    exit;
  fi

# AQUÍ DA ERROR
  if [ $FICHACENTRAL != 1 ] && [ $FICHACENTRAL != 2 ];then
    echo -e "\e[1;31mERROR\e[0m. No se ha introducido un valor correcto de la FICHACENTRAL (1 o 2)."
    exit;
  fi
}
Configuracion(){
  echo
}

Jugar(){
  echo
}

Estadisticas(){
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
      Menu
    ;;
  esac
}

Comprobar-g
ComprobarConf
# DESPUÉS DE JUGAR VUELVE AQUÍ
#clear
Menu
