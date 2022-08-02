
# Installs dependencies with or without development packages depending on environment
case $CURRENT_ENV in

  development)
    bundle install
    ;;

  production)
    bundle install --deployment --without test,development
    ;;

  *)
    echo "No environment selected";
    exit 1
    ;;
esac
