## Script para exportar la placa a distintos formatos
## .grb .drl .svg .step

EXPORT_DIRECTORY=exports
FABRICATION_DIRECTORY=fabrication

print_help() {
  echo "Uso: ./export.sh [-f]

  El argumento -f es opcional e indica exportar los archivos .grb y .drl."
}

export_svg() {
  # Exporto a SVG y cambio dentro de los archivos la opacidad de las zonas rellenas
  kicad-cli pcb export svg\
    --page-size-mode 2\
    --layers User.Drawings,F.Silkscreen,Edge.Cuts,F.Courtyard,F.Fab,F.Cu\
    modulo_sensor.kicad_pcb

  sed "s/C83434; fill-opacity:1.0000/C83434; fill-opacity:0.5000/g"\
    < modulo_sensor.svg > aux.svg

  sed "s/stroke:#000000; stroke-width:0.1500; stroke-opacity:1;/stroke:#000000; stroke-width:0.1500; stroke-opacity:0;/g"\
    < aux.svg > $EXPORT_DIRECTORY/front_preview.svg

  kicad-cli pcb export svg\
    --page-size-mode 2\
    --layers User.Drawings,B.Silkscreen,Edge.Cuts,B.Courtyard,B.Fab,B.Cu\
    modulo_sensor.kicad_pcb

  sed "s/4D7FC4; fill-opacity:1.0000/4D7FC4; fill-opacity:0.3500/g"\
    < modulo_sensor.svg > $EXPORT_DIRECTORY/bottom_preview.svg

  rm modulo_sensor.svg aux.svg
}

export_drl() {
  # Genero archivos .drl
  kicad-cli pcb export drill --output $FABRICATION_DIRECTORY\
    --drill-origin absolute\
    --excellon-oval-format route\
    --excellon-units in\
    --excellon-separate-th\
    modulo_sensor.kicad_pcb
}

export_grb(){
  # Genero archivos .grb (Hardcodeo las layers)
  kicad-cli pcb export gerbers --output $FABRICATION_DIRECTORY\
    --layers F.Cu,B.Cu,F.Paste,B.Paste,F.Silkscreen,B.Silkscreen,F.Mask,B.Mask,Edge.Cuts\
    --no-protel-ext\
    modulo_sensor.kicad_pcb
}

export_step(){
  # Genero archivos .step
  kicad-cli pcb export step modulo_sensor.kicad_pcb\
    --output $EXPORT_DIRECTORY/modulo_sensor.step\
    --no-unspecified\
    --no-dnp\
    --drill-origin\
    --subst-models\
    --no-optimize-step 
    # --include-tracks\
    # --include-zones\
}

# Checkeo argumentos
if [[ $# -ne 0 && $1 == @(-h|--help) ]]; then
	print_help
	exit 0
elif [[ $# -ne 0 && !($1 == @(-h|--help|-f)) ]]; then 
  print_help
  exit 1
fi

# Ejecuto el script
printf "Exportando SVG..........................................\n"
export_svg

printf "Exportando STEP.........................................\n"
export_step

if [ $# -ne 0 ] && [ $1 == "-f" ]; then
	printf "\nExportando .drl y .grb .................................\n"
	export_drl
	export_grb

	printf "\nComprimiendo .drl y .grb  -> fabrication.zip............\n"
  zip $FABRICATION_DIRECTORY/fabrication.zip $FABRICATION_DIRECTORY/*
fi
