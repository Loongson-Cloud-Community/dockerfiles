#!/bin/bash

print_all_repository() {
	echo "---------------Repository Statistics---------------------------------"
	repos=($(find . -mindepth 3 -maxdepth 3 -type d ! -path '*/.git/*' -print))
	for repo in ${repos[@]}
	do
		echo ${repo#*\/}
	done

	echo ""
	echo "repository: ${#repos[@]}"
	echo "---------------------------------------------------------------------"
}


main(){
	print_all_repository
}

main
