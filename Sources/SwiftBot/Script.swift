//
//  Script.swift
//  SKClient
//
//  Created by Tomoya Hirano on 2018/12/23.
//

enum ShellScript {
  static let runDocker = """
#!/bin/bash
set -e

to=$1
shift

cont=$(docker run --rm -d --network none "$@")
code=$(timeout "$to" docker wait "$cont" || true)
docker kill $cont &> /dev/null
echo -n 'status: '
if [ -z "$code" ]; then
echo timeout
else
echo exited: $code
fi

docker logs $cont | sed 's/^/\t/'
docker rm $cont &> /dev/null
"""

  static let runSwift = """
#!/bin/bash

echo $SWIFT_VERSION > /usercode/version

exec 1> "/usercode/log"
exec 2> "/usercode/errors"

$@ /usercode/main.swift

mv /usercode/log /usercode/completed
"""
}




