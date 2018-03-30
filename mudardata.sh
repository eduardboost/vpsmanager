#!/bin/bash
tput setaf 7 ; tput setab 4 ; tput bold ; printf '%33s%s%-12s\n' "Mudar data de expiração" ; tput sgr0
echo ""
tput bold ; echo "Lista de usuarios y fecha de expiracion:" ; tput sgr0
echo ""
tput setaf 3 ; tput bold 
awk -F : '$3 >= 500 { print $1 }' /etc/passwd | grep -v '^nobody' | while read user
  do
	expire="$(chage -l $user | grep -E "Account expires" | cut -d ' ' -f3-)"
	if [[ $expire == "never" ]]
	then
		nunca="Nunca"
		printf '  %-30s%s\n' "$user" "Nunca"
	else
		databr="$(date -d "$expire" +"%Y%m%d")"
		hoje="$(date -d today +"%Y%m%d")"
		if [ $hoje -ge $databr ]
		then
			datanormal="$(date -d"$expire" '+%d/%m/%Y')"
			printf '  %-30s%s' "$user" "$datanormal" ; tput setaf 1 ; tput bold ; echo " (Expirado)" ; tput setaf 3
			echo "exp" > /tmp/exp
		else
			datanormal="$(date -d"$expire" '+%d/%m/%Y')"
			printf '  %-30s%s\n' "$user" "$datanormal"
		fi
	fi
  done
tput sgr0
echo ""
if [ -a /tmp/exp ]
then
	tput setaf 2 ; tput bold ; echo "Para remover todos los usuarios expirados use el comando: expcleaner" ; echo "" ; tput sgr0
	rm /tmp/exp
fi
read -p "Nombre de usuario para modificar la expiracion: " usuario
if [[ -z $usuario ]]
then
	echo ""
	tput setaf 7 ; tput setab 4 ; tput bold ; echo "Usuario inexistente o invalido!" ; tput sgr0
	echo ""
	exit 1
else
	if [[ `grep -c /$usuario: /etc/passwd` -ne 0 ]]
	then
		read -p "Ingrese nueva fecha de expiracion (DIA/MES/AÑO): " inputdate
		sysdate="$(echo "$inputdate" | awk -v FS=/ -v OFS=- '{print $3,$2,$1}')"
		if (date "+%Y-%m-%d" -d "$sysdate" > /dev/null  2>&1)
		then
			if [[ -z $inputdate ]]
			then
				echo ""
				tput setaf 7 ; tput setab 4 ; tput bold ;	echo "Inserto una fecha invalida!" ; echo "Inserte una fecha en el formato DIA/MES/AÑO" ; echo "Por ejemplo: 21/04/2048" ; tput sgr0
				echo ""
				exit 1	
			else
				if (echo $inputdate | egrep [^a-zA-Z] &> /dev/null)
				then
					today="$(date -d today +"%Y%m%d")"
					timemachine="$(date -d "$sysdate" +"%Y%m%d")"
					if [ $today -ge $timemachine ]
					then
						echo ""
						tput setaf 7 ; tput setab 4 ; tput bold ;	echo "Fecha antigua o dia actual!" ; echo "Inserte una fecha en el formato DIA/MES/AÑO" ; echo "Por ejemplo: 21/04/2048" ; tput sgr0
						echo ""
						exit 1
					else
						chage -E $sysdate $usuario
						echo ""
						tput setaf 7 ; tput setab 1 ; tput bold ; echo "La fecha de expiracion del usuario $usuario fue modificada para: $inputdate" ; tput sgr0
						echo ""
						exit 1
					fi
				else
					echo ""
					tput setaf 7 ; tput setab 4 ; tput bold ;	echo "Inserto un dato invalido!" ; echo "Inserte una fecha en el formato DIA/MES/AÑO" ; echo "Por ejemplo: 21/04/2048" ; tput sgr0
					echo ""
					exit 1
				fi
			fi
		else
			echo ""
			tput setaf 7 ; tput setab 4 ; tput bold ;	echo "Inserto un dato invalido!" ; echo "Inserte una fecha en el formato DIA/MES/AÑO" ; echo "Por exemplo: 21/04/2048" ; tput sgr0
			echo ""
			exit 1
		fi
	else
		echo " "
		tput setaf 7 ; tput setab 4 ; tput bold ;	echo "El usuario $usuario no existe!" ; tput sgr0
		echo " "
		exit 1
	fi
fi