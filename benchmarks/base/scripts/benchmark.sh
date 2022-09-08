#!/bin/bash

cat > /tmp/select_query.sql <<EOF
SELECT * FROM employees;SELECT * FROM titles;SELECT * FROM dept_emp;SELECT * FROM dept_manager;SELECT * FROM departments
EOF

for qf in /scripts/benchmark_query.sql /tmp/select_query.sql; do
	if [ -f "$qf" ]; then
		query_file="$qf"
		break
	fi
done

if [ -z "$query_file" ]; then
	echo "ERROR: no query file" >&2
	exit 1
fi

suffix="$(cut -f2 -d- <<<"${POD_NAME}")"

common_args=(
	"--host=mariadb-${suffix}"
	"--user=root"
	"--password=${MARIADB_ROOT_PASSWORD}"
)

while ! mysql "${common_args[@]}" -e 'select 1' "${MARIADB_DATABASE}" > /dev/null 2>&1; do
	echo "waiting for database..."
	sleep 1
done

echo "running benchmarks with synthesized data..."
mysqlslap \
	"${common_args[@]}" \
	--auto-generate-sql \
	--concurrency="${MYSQLSLAP_CONCURRENCY:=100}" \
	--number-of-queries="${MYSQLSLAP_NUM_QUERYES:=1000}" \
	--number-char-cols="${MYSQLSLAP_NUM_CHAR_COLUMNS:=4}" \
	--number-int-cols="${MYSQLSLAP_NUM_INT_COLUMNS:=7}"

echo "running benchmarks with sample data..."
echo "reading queries from: $query_file"
mysqlslap \
	"${common_args[@]}" \
	--concurrency=20 \
	--number-of-queries=1000 \
	--create-schema=employees \
	--delimiter=";" \
	--verbose \
	--iterations=2 \
	--debug-info \
	--query="${query_file}"
