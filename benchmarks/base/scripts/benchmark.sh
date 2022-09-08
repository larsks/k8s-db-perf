#!/bin/bash

set_state() {
	mysql "${common_args[@]}" \
		-e "replace into state (tag, state) values (\"$tag\", \"$1\")" results
}

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

tag="$(cut -f2 -d- <<<"${POD_NAME}")"

common_args=(
	"--host=mariadb-${tag}"
	"--user=root"
	"--password=${MARIADB_ROOT_PASSWORD}"
)

while ! mysql "${common_args[@]}" -e 'select 1' "${MARIADB_DATABASE}" > /dev/null 2>&1; do
	echo "waiting for database..."
	sleep 1
done

mkdir -p /tmp/results

set_state "run1"
echo "running benchmarks with synthesized data..."
mysqlslap \
	"${common_args[@]}" \
	--debug-info \
	--auto-generate-sql \
	--concurrency="${MYSQLSLAP_CONCURRENCY:=100}" \
	--number-of-queries="${MYSQLSLAP_NUM_QUERYES:=1000}" \
	--number-char-cols="${MYSQLSLAP_NUM_CHAR_COLUMNS:=4}" \
	--number-int-cols="${MYSQLSLAP_NUM_INT_COLUMNS:=7}" \
	2>&1 | tee /tmp/results/run1.txt

set_state "run2"
echo "running benchmarks with sample data..."
echo "reading queries from: $query_file"
mysqlslap \
	"${common_args[@]}" \
	--debug-info \
	--concurrency=20 \
	--number-of-queries=1000 \
	--create-schema=employees \
	--delimiter=";" \
	--verbose \
	--iterations=2 \
	--query="${query_file}" \
	2>&1 | tee /tmp/results/run2.txt

set_state "saving results"
for fn in /tmp/results/run*.txt; do
	name=${fn%.txt}
	name=${name##*/}
	mysql "${common_args[@]}" \
		-e "insert into files (tag, name, content)
		values (\"$tag\", \"$name\", \"$(base64 -w0 "$fn")\")" results
done

set_state "complete"
