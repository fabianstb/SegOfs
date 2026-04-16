#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="planta-energia-vulnerable"
IMAGE_TAG="latest"
CONTAINER_NAME="planta-energia-vulnerable"
HOSTNAME_CTR="ENERGIA-SCADA01"
IMAGE_FILE="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/planta-energia-vulnerable.tar.gz}"
IMAGE_SHA256="63c45ed6894ce4a7b42efd03f46f2354f5f683ba6c741100d518662d479b296f"

PORTS=(
  "-p" "21:21"
  "-p" "2100-2130:2100-2130"
  "-p" "2222:22"
  "-p" "2323:23"
  "-p" "2525:25"
  "-p" "8080:80"
  "-p" "1139:139"
  "-p" "1445:445"
)

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

step() { echo -e "\n${BLUE}${BOLD}[*]${NC} ${BOLD}$*${NC}"; }
ok() { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
fail() { echo -e "${RED}[FAIL]${NC} $*"; exit 1; }

need_root_for_docker() {
  if docker info >/dev/null 2>&1; then
    return 0
  fi
  if [[ "${EUID}" -ne 0 ]]; then
    echo "Docker requiere permisos. Reejecutando con sudo..."
    exec sudo -E bash "$0" "$@"
  fi
}

check_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    fail "Docker no instalado. Instala Docker Engine y vuelve a ejecutar."
  fi
  if ! docker info >/dev/null 2>&1; then
    systemctl start docker >/dev/null 2>&1 || service docker start >/dev/null 2>&1 || true
  fi
  docker info >/dev/null 2>&1 || fail "Docker daemon no responde."
  ok "$(docker --version)"
}

check_image_file() {
  [[ -f "$IMAGE_FILE" ]] || fail "No existe imagen exportada: $IMAGE_FILE"
  ok "Imagen encontrada: $(du -h "$IMAGE_FILE" | cut -f1)"

  if command -v sha256sum >/dev/null 2>&1; then
    local got
    got="$(sha256sum "$IMAGE_FILE" | awk '{print $1}')"
    [[ "$got" == "$IMAGE_SHA256" ]] || fail "SHA256 no coincide. Esperado $IMAGE_SHA256, obtenido $got"
    ok "SHA256 verificado"
  else
    warn "sha256sum no disponible; salto verificacion de integridad."
  fi
}

load_image() {
  step "Cargando imagen Docker"
  gzip -dc "$IMAGE_FILE" | docker load
  docker image inspect "${IMAGE_NAME}:${IMAGE_TAG}" >/dev/null 2>&1 || fail "Imagen no quedo cargada como ${IMAGE_NAME}:${IMAGE_TAG}"
  ok "Imagen lista: ${IMAGE_NAME}:${IMAGE_TAG}"
}

stop_existing() {
  step "Limpiando contenedor previo"
  if docker ps -aq --filter "name=^/${CONTAINER_NAME}$" | grep -q .; then
    docker rm -f "$CONTAINER_NAME" >/dev/null
    ok "Contenedor previo eliminado"
  else
    ok "Sin contenedor previo"
  fi
}

start_container() {
  step "Levantando laboratorio"
  docker run -d \
    --name "$CONTAINER_NAME" \
    --hostname "$HOSTNAME_CTR" \
    --restart unless-stopped \
    --cap-add NET_ADMIN \
    --cap-add SYS_PTRACE \
    --security-opt seccomp=unconfined \
    "${PORTS[@]}" \
    "${IMAGE_NAME}:${IMAGE_TAG}" >/dev/null

  ok "Contenedor iniciado"
}

check_tcp() {
  local port="$1" name="$2"
  if timeout 3 bash -c "cat < /dev/null > /dev/tcp/127.0.0.1/${port}" 2>/dev/null; then
    ok "$name tcp/$port abierto"
  else
    fail "$name tcp/$port no responde"
  fi
}

verify_lab() {
  step "Verificando servicios"
  sleep 12
  check_tcp 21 FTP
  check_tcp 2222 SSH
  check_tcp 2323 TELNET
  check_tcp 2525 SMTP
  check_tcp 8080 WEB
  check_tcp 1139 SMB
  check_tcp 1445 SMB

  curl -fsS "http://127.0.0.1:8080/" >/dev/null || fail "WEB no carga"
  ok "WEB responde en http://127.0.0.1:8080/"
}

show_access() {
  echo ""
  echo -e "${CYAN}${BOLD}Planta Energia Vulnerable Lab listo${NC}"
  echo "WEB:     http://127.0.0.1:8080/"
  echo "FTP:     127.0.0.1:21"
  echo "SSH:     ssh -p 2222 root@127.0.0.1"
  echo "TELNET:  telnet 127.0.0.1 2323"
  echo "SMTP:    nc 127.0.0.1 2525"
  echo "SMB:     smbclient -N -p 1445 -L //127.0.0.1"
  echo ""
  echo "Detener:"
  echo "  docker rm -f ${CONTAINER_NAME}"
}

main() {
  need_root_for_docker "$@"
  check_docker
  check_image_file
  load_image
  stop_existing
  start_container
  verify_lab
  show_access
}

main "$@"
