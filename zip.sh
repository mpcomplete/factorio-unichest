#!/bin/sh
name=Unichest_1.0.5
mkdir $name
cp -a * $name
rm $name/*.sh $name/*.zip $name/$name $name/action.gif -rf
rm -rf ${name}.zip
7z a ${name}.zip $name
rm -rf $name
