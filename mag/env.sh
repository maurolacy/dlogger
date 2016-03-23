:

[ -z "$BASE" ] && BASE="`pwd`/.."

export QUICK2WIRE_API_HOME=$BASE/mag/quick2wire-python-api
export PYTHONPATH=$PYTHONPATH:$QUICK2WIRE_API_HOME

#echo "BASE: $BASE, QW: $QUICK2WIRE_API_HOME, PP: $PYTHONPATH" >/tmp/env.$$

#cd $QUICK2WIRE_API_HOME
