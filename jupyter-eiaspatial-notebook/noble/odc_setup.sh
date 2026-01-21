#!/usr/bin/env bash
set -e

ENV_NAME="odc"
PYTHON_VERSION="3.11"

DATACUBE_DIR="$HOME/.datacube"
CONFIG_FILE="$DATACUBE_DIR/datacube.conf"
DB_URL="postgresql://postgres_admin:12345678@postgres.scio.services:5432/odc"

echo "▶ Installing system dependencies"
sudo apt-get update
sudo apt-get install -y \
  libgdal-dev \
  libhdf5-serial-dev \
  libnetcdf-dev \
  gdal-bin \
  postgresql-client

echo "▶ Preparing datacube config"
mkdir -p "$DATACUBE_DIR"

cat > "$CONFIG_FILE" <<CONFIG_EOF
[datacube]
index_driver = postgis
db_url = $DB_URL
CONFIG_EOF

# HARD FAIL if config is missing
if [ ! -s "$CONFIG_FILE" ]; then
  echo "❌ datacube.conf was not created"
  exit 1
fi

echo "▶ datacube.conf created at $CONFIG_FILE"

echo "▶ Checking conda"
source "$(conda info --base)/etc/profile.d/conda.sh"

if ! conda env list | awk '{print $1}' | grep -qx "$ENV_NAME"; then
  conda create -y -n "$ENV_NAME" python="$PYTHON_VERSION"
fi

echo "▶ Installing Python packages into conda env"
conda run -n "$ENV_NAME" pip install --upgrade pip

conda run -n "$ENV_NAME" pip install \
  "datacube[postgres]==1.9.12" \
  odc-apps-dc-tools \
  datacube-explorer \
  boto3 \
  botocore \
  psycopg2-binary \
  rasterio \
  shapely \
  xarray \
  numpy \
  pandas \
  matplotlib \
  ipykernel

echo "▶ Registering Jupyter kernel"
conda run -n "$ENV_NAME" python -m ipykernel install \
  --user \
  --name "$ENV_NAME" \
  --display-name "Python ($ENV_NAME)"

KERNEL_JSON="$HOME/.local/share/jupyter/kernels/odc/kernel.json"

echo "▶ Injecting DATACUBE_CONFIG_PATH into Jupyter kernel "

python <<EOF
import json, os

path = os.path.expanduser("$KERNEL_JSON")
with open(path) as f:
    kernel = json.load(f)

env = kernel.get("env", {})
env["DATACUBE_CONFIG_PATH"] = os.path.expanduser("~/.datacube/datacube.conf")
kernel["env"] = env

with open(path, "w") as f:
    json.dump(kernel, f, indent=2)

print("✔ Kernel patched:", path)
EOF

echo "▶ Initializing database (safe to re-run)"
conda run \
  -n "$ENV_NAME" \
  env DATACUBE_CONFIG_PATH="$CONFIG_FILE" \
  datacube -v system init || true


echo "▶ Health check: datacube system check"
conda run \
  -n "$ENV_NAME" \
  env DATACUBE_CONFIG_PATH="$CONFIG_FILE" \
  datacube system check



echo "▶ Health check: products"
conda run \
  -n "$ENV_NAME" \
  env DATACUBE_CONFIG_PATH="$CONFIG_FILE" \
  datacube product list || true

echo
echo "✔ Open Data Cube installed and configured correctly"
