#!/bin/bash
prject_name=cmi
project_dir=$(pwd)
latest_branch=$(git tag | grep -Po 'v\d+\.\d+\.\d+' | tail -1)
current_branch=$(git branch | sed -n '/\*/p' | cut -d ' ' -f 2)
version=$(echo $current_branch | sed -n 's/release-\(v[0-9]\+\.[0-9]\+\.[0-9]\+\)/\1/p')
if [[ -z "$version" ]]; then
    version=$(echo $current_branch | sed -n 's/hotfix-\(v[0-9]\+\.[0-9]\+\.[0-9]\+\)/\1/p')
fi
if [[ -z "$version" ]]; then
    echo not on a release branch nor a hotfix branch
    exit 1
fi
echo 'gen release.log'
echo "--$version" > doc/release.log.tmp
git log $latest_branch...$current_branch --grep "^[+]" --pretty=format:'%B' >> doc/release.log.tmp
git log $latest_branch...$current_branch --grep "^[-]" --pretty=format:'%B' >> doc/release.log.tmp
git log $latest_branch...$current_branch --grep "^[!]" --pretty=format:'%B' >> doc/release.log.tmp
git log $latest_branch...$current_branch --grep "^[*]" --pretty=format:'%B' >> doc/release.log.tmp

cd ./6web
6web_latest_branch=$(git tag | grep -Po "^$project_name-v\d+\.\d+\.\d+" | tail -1)
6web_second_latest_branch=$(git tag | grep -Po "^$project_name-v\d+\.\d+\.\d+" | tail -2 | head -1)
git log $6web_latest_branch...$6web_second_latest_branch --grep "^$project_name[+]" --pretty=format:'%B' >> $project_dir/doc/release.log.tmp
git log $6web_latest_branch...$6web_second_latest_branch --grep "^$project_name[-]" --pretty=format:'%B' >> $project_dir/doc/release.log.tmp
git log $6web_latest_branch...$6web_second_latest_branch --grep "^$project_name[!]" --pretty=format:'%B' >> $project_dir/doc/release.log.tmp
git log $6web_latest_branch...$6web_second_latest_branch --grep "^$project_name[*]" --pretty=format:'%B' >> $project_dir/doc/release.log.tmp
cd $project_dir

cat doc/release.log.tmp doc/release.log > doc/release.log.new
rm doc/release.log.tmp && mv doc/release.log.new doc/release.log
echo 'commit release.log'
git stage doc/release.log
git commit -m 'gen release.log'
echo tag $version
git tag $version
git checkout master && git merge $current_branch
git push
git push --tags
git checkout develop && git merge $current_branch
git push
