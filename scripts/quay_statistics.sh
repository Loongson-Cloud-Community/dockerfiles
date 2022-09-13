#!/bin/bash

#set -x

CSRF_TOKEN=
PAGE_TOKEN=

CSRF_TOKEN=$(cat .token)
ALL_REPOS=()
ALL_REPOS_TAGS=()
get_next_page()
{
	url="https://cr.loongnix.cn/api/v1/repository"
	out=$(curl -sL -H "Cookie: _csrf_token=$CSRF_TOKEN" -G -d "public=true" -d "next_page=$PAGE_TOKEN" $url)

	repos=($(echo $out | jq -r '.repositories[] | .namespace + "/" + .name'))

	ALL_REPOS=(${ALL_REPOS[@]} ${repos[@]})

	PAGE_TOKEN=$(echo $out | jq -r '.next_page')

	if [ ! "$PAGE_TOKEN" = "null" ];
	then
		get_next_page	
	fi
}

get_tags()
{
	repo=$1
	url="https://cr.loongnix.cn/api/v1/repository/$repo/tag"
	out=$(curl -sL $url)
	tags=$(echo $out | jq -r '.tags[] | '\"$repo:\"' + .name')
	
	ALL_REPOS_TAGS=(${ALL_REPOS_TAGS[@]} ${tags[@]})
}

print_tags()
{
	for tag in ${ALL_REPOS_TAGS[@]};
	do
		echo $tag
	done
}

get_next_page

# invoke get_tags
for repo in ${ALL_REPOS[@]};
do
	get_tags $repo
done

echo ${#ALL_REPOS_TAGS[@]}

#echo ${#ALL_REPOS[@]}

