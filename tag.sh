#!/bin/bash
project_name=cmi
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
echo $latest_branch
echo $current_branch
git log $latest_branch...$current_branch --grep "\[+\]" --pretty=format:'%B' >> doc/release.log.tmp
git log $latest_branch...$current_branch --grep "\[-\]" --pretty=format:'%B' >> doc/release.log.tmp
git log $latest_branch...$current_branch --grep "\[!\]" --pretty=format:'%B' >> doc/release.log.tmp
git log $latest_branch...$current_branch --grep "\[\*\]" --pretty=format:'%B' >> doc/release.log.tmp

cd ./6web
submodule_latest_branch=$(git tag | grep -Po "^$project_name-v\d+\.\d+\.\d+" | tail -1)
submodule_second_latest_branch=$(git tag | grep -Po "^$project_name-v\d+\.\d+\.\d+" | tail -2 | head -1)
echo 6web latest tag $submodule_latest_branch
echo 6web second latest tag $submodule_second_latest_branch
if [[ -z "$submodule_latest_branch" ]] || [[ -z "$submodule_second_latest_branch" ]]; then
  echo no proper tag found in 6web
else
  git log $submodule_latest_branch...$submodule_second_latest_branch --grep "$project_name\[+\]" --pretty=format:'%B' | sed "s/^$project_name/backend/g" >> $project_dir/doc/release.log.tmp
  git log $submodule_latest_branch...$submodule_second_latest_branch --grep "$project_name\[-\]" --pretty=format:'%B' | sed "s/^$project_name/backend/g" >> $project_dir/doc/release.log.tmp
  git log $submodule_latest_branch...$submodule_second_latest_branch --grep "$project_name\[!\]" --pretty=format:'%B' | sed "s/^$project_name/backend/g" >> $project_dir/doc/release.log.tmp
  git log $submodule_latest_branch...$submodule_second_latest_branch --grep "$project_name\[\*\]" --pretty=format:'%B' | sed "s/^$project_name/backend/g" >> $project_dir/doc/release.log.tmp
fi
cd $project_dir

if [[ $(cat doc/release.log | grep -- "--$version") ]]; then
  sed -i "/--$version/d" doc/release.log
else
  echo "" >> doc/release.log.tmp
fi

cat doc/release.log.tmp doc/release.log > doc/release.log.new
rm doc/release.log.tmp && mv doc/release.log.new doc/release.log
echo 'commit release.log'
git stage doc/release.log
git commit -m 'gen release.log'
echo tag $version
existed_tag=$(git tag | grep $version)
if [[ -z "existed_tag" ]]; then
  git tag $version
else
  git push origin :refs/tags/$version
  git tag -f $version
fi
git push origin $current_branch
git checkout master && git merge $current_branch
git push
git push --tags
git checkout develop && git merge $current_branch
git push
