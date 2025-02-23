kpatch() {
    kubectl patch deployment $1 -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}"
}

pjq() {
    sed 's/'\''/"/g' | sed 's/None/null/g' | sed 's/True/true/g' | sed 's/False/false/g' | jq
}

urldecode() {
  echo -e "$(sed 's/+/ /g;s/%\(..\)/\\x\1/g;')"
}

gch() {
  git checkout "$(git branch --all | sed 's/remotes\/origin\///' | sort -u | fzf | tr -d '[:space:]')"
}

source-env () {
    set -o allexport
    source $1
    set +o allexport
}

kenv () {
    HELP_MSG='Usage

    kenv list - Show possible environments
    kenv <environment> - Switch to the given environment'
    LIST_MSG='local
test
prod'

    if [ -z "$1" ]
    then
        echo $HELP_MSG;
    fi

    case $1 in
        "list")
            echo $LIST_MSG
            ;;
        "local")
            kubectl config use-context rancher-desktop
            ;;
        "staging")
            kubectl config use-context main-staging-aks-new
            ;;
        "pci-staging")
            kubectl config use-context pci-stag-aks
            ;;
        "prep")
            kubectl config use-context main-cluster-prep-aks
            ;;
        "prod")
            kubectl config use-context main-cluster-prod-aks
            ;;
        "pci-prod")
            kubectl config use-context pci-prod-aks
            ;;
    esac

    tmux refresh-client -S
}

k8s-auth() {
    az account clear
    az login
}

clean-js-files() {
    find ${1:-.} -name '*.ts' | sed 's/.ts$/.js/' | xargs rm -f
}

# port-forward
pf() {
    SEARCH=$1
    PORT=$2
    shift 2

    POD=$(kubectl get pods --no-headers -o custom-columns=":metadata.name" $@ | grep $SEARCH | head -n1)
    echo "Found pod: ${POD}"
    kubectl port-forward $POD $PORT $@
}

git-set-upstream() {
    BRANCH=$(git branch --show-current)
    git branch --set-upstream-to=origin/$BRANCH $BRANCH
}

uuid-from-stitch-id() {
    STITCH_ID=$1
    echo $1 | base64 -D | cut -d '/' -f2
}
