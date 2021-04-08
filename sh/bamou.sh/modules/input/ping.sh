m_ping(){
 HOST="${HOST:-$1}"
 COUNT="${COUNT:-$2}"
 COUNT="${COUNT:-3}" #fallback count
 ping -c "$COUNT" "$HOST"
}
