# Pre-requisites
source .env

# Declare and deploy contracts
MOCKUSDC_CLASS=$(starkli declare ./target/dev/meson_starknet_MockToken.contract_class.json | tail -n 1)
MOCKUSDC_ADDRESS=$(starkli deploy $MOCKUSDC_CLASS $ADDRESS_ADMIN | tail -n 1)
MESON_CLASS=$(starkli declare ./target/dev/meson_starknet_Meson.contract_class.json | tail -n 1)
MESON_ADDRESS=$(starkli deploy $MESON_CLASS $ADDRESS_ADMIN | tail -n 1)

# Update .env file
if grep -q "MOCKUSDC_ADDRESS=" .env; then
  sed -i '' -e "s/MOCKUSDC_ADDRESS=.*/MOCKUSDC_ADDRESS=$MOCKUSDC_ADDRESS/" .env
else
  echo "MOCKUSDC_ADDRESS=$MOCKUSDC_ADDRESS" >> .env
fi
if grep -q "MESON_ADDRESS=" .env; then
  sed -i '' -e "s/MESON_ADDRESS=.*/MESON_ADDRESS=$MESON_ADDRESS/" .env
else
  echo "MESON_ADDRESS=$MESON_ADDRESS" >> .env
fi
