#!/bin/bash
#
# Cases relevant to Oil's:
#
# - shopt -s more_errexit
# - and maybe inherit_errexit and strict_errexit (OSH)
#
# Summary:
# - errexit is reset to false in ash/bash -- completely ignored!
# - local assignment is different than global!  The exit code and errexit
# behavior are different because the concept of the "last command" is
# different.
# - ash has copied bash behavior!

#### command sub: errexit is NOT inherited and outer shell keeps going

# This is the bash-specific bug here:
# https://blogs.janestreet.com/when-bash-scripts-bite/
# See inherit_errexit below.
#
# I remember finding a script that relies on bash's bad behavior, so OSH copies
# it.  Instead more_errexit, is recommended.

set -o errexit
echo $(echo one; false; echo two)  # bash/ash keep going
echo parent status=$?
## STDOUT:
one two
parent status=0
## END
# dash and mksh: inner shell aborts, but outer one keeps going!
## OK dash/mksh STDOUT:
one
parent status=0
## END

#### command sub with inherit_errexit only
set -o errexit
shopt -s inherit_errexit || true
echo zero
echo $(echo one; false; echo two)  # bash/ash keep going
echo parent status=$?
## STDOUT:
zero
one
parent status=0
## END
## N-I ash STDOUT:
zero
one two
parent status=0
## END

#### command sub with more_errexit only
set -o errexit
shopt -s more_errexit || true
echo zero
echo $(echo one; false; echo two)  # bash/ash keep going
echo parent status=$?
## STDOUT:
zero
one two
parent status=0
## END
## N-I dash/mksh STDOUT:
zero
one
parent status=0
## END

#### command sub with inherit_errexit and more_errexit
set -o errexit

# bash implements inherit_errexit, but it's not as strict as OSH.
shopt -s inherit_errexit || true
shopt -s more_errexit || true
echo zero
echo $(echo one; false; echo two)  # bash/ash keep going
echo parent status=$?
## STDOUT:
zero
## END
## status: 1
## N-I dash/mksh/bash status: 0
## N-I dash/mksh/bash STDOUT:
zero
one
parent status=0
## END
## N-I ash status: 0
## N-I ash STDOUT:
zero
one two
parent status=0
## END

#### command sub: last command fails but keeps going and exit code is 0
set -o errexit
echo $(echo one; false)  # we lost the exit code
echo status=$?
## STDOUT:
one
status=0
## END

#### global assignment with command sub: middle command fails
set -o errexit
s=$(echo one; false; echo two;)
echo "$s"
## status: 0
## STDOUT:
one
two
## END
# dash and mksh: whole thing aborts!
## OK dash/mksh stdout-json: ""
## OK dash/mksh status: 1

#### global assignment with command sub: last command fails and it aborts
set -o errexit
s=$(echo one; false)
echo status=$?
## stdout-json: ""
## status: 1

#### local: middle command fails and keeps going
set -o errexit
f() {
  echo good
  local x=$(echo one; false; echo two)
  echo status=$?
  echo $x
}
f
## STDOUT:
good
status=0
one two
## END
# for dash and mksh, the INNER shell aborts, but the outer one keeps going!
## OK dash/mksh STDOUT:
good
status=0
one
## END

#### local: last command fails and also keeps going
set -o errexit
f() {
  echo good
  local x=$(echo one; false)
  echo status=$?
  echo $x
}
f
## STDOUT:
good
status=0
one
## END

#### local and inherit_errexit / more_errexit
# I've run into this problem a lot.
set -o errexit
shopt -s inherit_errexit || true  # bash option
shopt -s more_errexit || true  # oil option
f() {
  echo good
  local x=$(echo one; false; echo two)
  echo status=$?
  echo $x
}
f
## status: 1
## STDOUT:
good
## END
## N-I ash status: 0
## N-I ash STDOUT:
good
status=0
one two
## END
## N-I bash/dash/mksh  status: 0
## N-I bash/dash/mksh STDOUT:
good
status=0
one
## END

#### global assignment when last status is failure
# this is a bug I introduced
set -o errexit
[ -n "${BUILDDIR+x}" ] && _BUILDDIR=$BUILDDIR
BUILDDIR=${_BUILDDIR-$BUILDDIR}
echo status=$?
## STDOUT:
status=0
## END

#### global assignment when last status is failure
# this is a bug I introduced
set -o errexit
x=$(false) || true   # from abuild
[ -n "$APORTSDIR" ] && true
BUILDDIR=${_BUILDDIR-$BUILDDIR}
echo status=$?
## STDOUT:
status=0
## END

#### strict_errexit
set -o errexit
func() { echo func; }

func || true  # this is OK

shopt -s strict_errexit || true

echo 'builtin ok' || true
/bin/echo 'external ok' || true

func || true  # this fails

## status: 1
## STDOUT:
func
builtin ok
external ok
## END
## N-I dash/bash/mksh/ash status: 0
## N-I dash/bash/mksh/ash STDOUT:
func
builtin ok
external ok
func
## END

#### strict_errexit and ! && || if while until
prelude='set -o errexit
shopt -s strict_errexit || true
func() { echo func; }'

$SH -c "$prelude; ! func; echo 'should not get here'"
echo bang=$?
echo --

$SH -c "$prelude; func || true"
echo or=$?
echo --

$SH -c "$prelude; func && true"
echo and=$?
echo --

$SH -c "$prelude; if func; then true; fi"
echo if=$?
echo --

$SH -c "$prelude; while func; do echo while; exit; done"
echo while=$?
echo --

$SH -c "$prelude; until func; do echo until; exit; done"
echo until=$?
echo --


## STDOUT:
bang=1
--
or=1
--
and=1
--
if=1
--
while=1
--
until=1
--
## END
## N-I dash/bash/mksh/ash STDOUT:
func
should not get here
bang=0
--
func
or=0
--
func
and=0
--
func
if=0
--
func
while
while=0
--
func
until=0
--
## END
