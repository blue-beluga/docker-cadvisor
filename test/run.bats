#!/usr/bin/env bats

setup() {
  docker history "$REGISTRY/$REPOSITORY:$TAG" >/dev/null 2>&1
  export IMG="$REGISTRY/$REPOSITORY:$TAG"
}

@test "the image has a disk size under 10MB" {
    run docker images $IMG
    echo 'status:' $status
    echo 'output:' $output
    size="$(echo ${lines[1]} | awk -F '   *' '{ print int($5) }')"
    echo 'size:' $size
    [ "$status" -eq 0 ]
    [ $size -lt 10 ]
}

@test "the image has cadvisor installed" {
  run docker run --rm --entrypoint=/bin/sh $IMG -c '[ -x /usr/bin/cadvisor ]'
  echo 'status:' $status
  [ "$status" -eq 0 ]
}

@test "that the root password is disabled" {
  run docker run --user nobody $IMG su
  [ $status -eq 1 ]
}

@test "the image entrypoint should be the cadvisor wrapper" {
  run bash -c "docker inspect $IMG | jq -r '.[].Config.Entrypoint[]'"
  echo 'status:' $status
  echo 'output:' $output
  [ "$status" -eq 0 ]
  [ "$output" = "/entrypoint.sh" ]
}
