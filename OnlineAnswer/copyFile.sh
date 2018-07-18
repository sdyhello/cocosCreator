echo "copy file to main folder......"
rm -rf build/onlineAnswer
mv "build/web-mobile" "build/onlineAnswer"
rm -rf ../../Arkad/ArkadGame/game/OnlineAnswer
cp -R build/OnlineAnswer ../../Arkad/ArkadGame/game
