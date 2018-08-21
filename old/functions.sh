## 

function git_last_change_date {
    pushd $1 > /dev/null
    DATE=$(git log -1 --format=%ct | xargs -I {{}} sh -c "date -d \@{{}} +%Y%m%d%H%M")
    echo $DATE
    popd > /dev/null
}


function git_update {
  pushd $1 > /dev/null
  git pull
  git checkout $2

  popd > /dev/null
}


function replace_qualifier_in_file {
    find $1 -name $2 -exec sed -i -e "s/qualifier/$3/g" {} \;
}
