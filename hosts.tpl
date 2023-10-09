[${ node_group }]
%{ for node, ip in nodes ~}
${ ip }    node_name=${ node }
%{ endfor ~}

