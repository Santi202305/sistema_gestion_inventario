#!/usr/bin/env bash
set -e

BASE_URL="http://localhost:3000/api"
OUT_FILE="docs/evidencias/api_pruebas.txt"
mkdir -p docs/evidencias

echo "==========================================================" > "$OUT_FILE"
echo "EVIDENCIAS DE PRUEBAS DE LA API REST - SISTEMA DE INVENTARIO" >> "$OUT_FILE"
echo "Fecha y hora: $(date)" >> "$OUT_FILE"
echo "Base URL: $BASE_URL" >> "$OUT_FILE"
echo "==========================================================" >> "$OUT_FILE"

run_test() {
  local title="$1"
  local method="$2"
  local url="$3"
  local data="$4"

  echo "" >> "$OUT_FILE"
  echo "----------------------------------------------------------" >> "$OUT_FILE"
  echo "PRUEBA: $title" >> "$OUT_FILE"
  echo "METODO: $method $url" >> "$OUT_FILE"
  if [ -n "$data" ]; then
    echo "PAYLOAD ENVIADO: $data" >> "$OUT_FILE"
  fi
  echo "RESPUESTA HTTP:" >> "$OUT_FILE"

  if [ -n "$data" ]; then
    curl -i -s -X "$method" "$url" \
      -H "Content-Type: application/json" \
      -d "$data" >> "$OUT_FILE"
  else
    curl -i -s -X "$method" "$url" >> "$OUT_FILE"
  fi
  echo "" >> "$OUT_FILE"
}

# 1. GET /api/productos (200)
run_test "1. Listar todos los productos" "GET" "$BASE_URL/productos"

# 2. GET /api/productos/1 (200)
run_test "2. Obtener producto por ID existente (ID 1)" "GET" "$BASE_URL/productos/1"

# 3. GET /api/productos/9999 (404)
run_test "3. Obtener producto inexistente (404)" "GET" "$BASE_URL/productos/9999"

# 4. POST /api/productos (201)
run_test "4. Registrar nuevo producto válido" "POST" "$BASE_URL/productos" \
'{"nombre":"Micrófono Condensador USB","codigo":"MIC-001","descripcion":"Micrófono cardioide con trípode y filtro anti-pop","precio":135000.0,"cantidad":12,"categoria":"Audio"}'

# 5. POST /api/productos (422) - Campos obligatorios vacíos
run_test "5. Error 422 - Campos obligatorios vacíos" "POST" "$BASE_URL/productos" \
'{"nombre":"","codigo":"","precio":null,"cantidad":null,"categoria":""}'

# 6. POST /api/productos (422) - Precio negativo y cantidad decimal
run_test "6. Error 422 - Precio negativo y cantidad decimal" "POST" "$BASE_URL/productos" \
'{"nombre":"Producto Invalido","codigo":"INV-001","precio":-500,"cantidad":3.5,"categoria":"Pruebas"}'

# 7. POST /api/productos (422) - Código duplicado
run_test "7. Error 422 - Código duplicado en POST" "POST" "$BASE_URL/productos" \
'{"nombre":"Mouse Duplicado","codigo":"TEC-001","precio":50000,"cantidad":5,"categoria":"Tecnología"}'

# 8. PUT /api/productos/1 (200)
run_test "8. Actualizar producto existente con datos válidos" "PUT" "$BASE_URL/productos/1" \
'{"nombre":"Mouse Inalámbrico Ergonómico Pro","codigo":"TEC-001","descripcion":"Versión Pro actualizada con batería de larga duración y sensor óptico 2400 DPI","precio":52000.0,"cantidad":20,"categoria":"Tecnología"}'

# 9. PUT /api/productos/9999 (404)
run_test "9. Actualizar producto inexistente (404)" "PUT" "$BASE_URL/productos/9999" \
'{"nombre":"No Existe","codigo":"NOEX-999","precio":10000,"cantidad":1,"categoria":"General"}'

# 10. PUT /api/productos/1 (422) - Código duplicado de otro producto
run_test "10. Error 422 - Código duplicado de otro producto en PUT" "PUT" "$BASE_URL/productos/1" \
'{"nombre":"Conflicto de código","codigo":"TEC-002","precio":45000,"cantidad":10,"categoria":"Tecnología"}'

# 11. DELETE /api/productos/12 (200)
run_test "11. Eliminar producto existente (ID 12)" "DELETE" "$BASE_URL/productos/12"

# 12. DELETE /api/productos/9999 (404)
run_test "12. Eliminar producto inexistente (404)" "DELETE" "$BASE_URL/productos/9999"

echo "Pruebas de API finalizadas. Evidencias guardadas en $OUT_FILE"
