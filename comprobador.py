import os
import sys

def generar_nombre_nuevo(ruta_base, root, file):
    ruta_relativa = os.path.relpath(root, ruta_base)
    partes = ruta_relativa.split(os.sep)

    # Si estamos en la raíz, no añadimos nada
    if partes == ['.']:
        return file

    # Si hay subcarpetas, las añadimos al nombre
    return "-".join(partes + [file])

def listar_archivos_con_nombres_nuevos(ruta):
    archivos = []
    for root, dirs, files in os.walk(ruta):
        for f in files:
            nuevo = generar_nombre_nuevo(ruta, root, f)
            archivos.append(nuevo)
    return archivos

def comprobar_copias(origen, destino):
    print("Comprobando archivos...")

    # Nombres generados igual que el script de mover
    originales = listar_archivos_con_nombres_nuevos(origen)

    # Archivos reales en DESTINO
    copiados = os.listdir(destino)

    set_originales = set(originales)
    set_copiados = set(copiados)

    faltan = set_originales - set_copiados

    print(f"Total originales: {len(originales)}")
    print(f"Total copiados: {len(copiados)}")

    if not faltan:
        print("✔ Todos los archivos han sido copiados correctamente")
    else:
        print("❌ Faltan archivos por copiar:")
        for f in sorted(faltan):
            print(f" - {f}")

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "-c":
        ORIGEN = "Planos originales"
        DESTINO = "DESTINO"
        comprobar_copias(ORIGEN, DESTINO)
    else:
        print("Ejecuta con '-c' para comprobar copias")
