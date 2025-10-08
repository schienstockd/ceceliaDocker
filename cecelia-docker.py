# Launch jupyter and docker
import os
import platform
import time
import shutil
# import IPython
from jupyter_client import KernelManager
from multiprocessing import Process
import urllib.request
import webbrowser

# get directories for jupyter files
dir_name = os.path.dirname(__file__)

datashare_path = os.path.join(dir_name, 'datashare')

# get connection files
conn_file = os.path.join(datashare_path, 'connectionFile.json')
debug_file = os.path.join(datashare_path, 'connectionFile.debug.json')
shiny_url = 'http://localhost:6860'

# start ipython kernel detached
# DOESN'T WORK ANYMORE
# def start_ipython(conn_file):
#   print('>> Start IPython')
#   
#   IPython.start_kernel(argv=[f'-f={conn_file}'])

# start ipython kernel detached
def start_docker(datashare_path):
  print('>> Start Docker')

  # Docker compose is a bit complicated
  # https://github.com/docker/compose/issues/1487
  if platform.system() != 'Windows':
    # os.system(f'export JUPYTER_LIB_DIR="{datashare_path}" && docker compose up --build -V --remove-orphans --force-recreate')
    os.system(f'export JUPYTER_LIB_DIR="{datashare_path}" && DOCKER_DEFAULT_PLATFORM=linux/amd64 docker compose up --build -V')
  else:
    # escape backslashes for R
    datashare_path = datashare_path.replace('\\', '\\\\')
    # os.system(f'set JUPYTER_LIB_DIR={datashare_path} && docker compose up --build -V --remove-orphans --force-recreate')
    os.system(f'set JUPYTER_LIB_DIR={datashare_path} && DOCKER_DEFAULT_PLATFORM=linux/amd64 docker compose up --build -V')

if __name__ == '__main__':
  if os.path.exists(datashare_path) is False:
    os.makedirs(datashare_path)

  print('>> Remove connection files')

  # remove connection file for IPython kernel
  if os.path.exists(debug_file):
    os.remove(debug_file)
  if os.path.exists(conn_file):
    os.remove(conn_file)

  # start ipython
  # p1 = Process(target = start_ipython, args = (debug_file,))
  # p1.start()
  # 
  # # wait until jupyter started and replace for docker
  # ipython_init = False
  # 
  # print('>> wait for kernel...')
  # 
  # while ipython_init is False:
  #   if os.path.exists(debug_file):
  #     ipython_init = True
  #   else:
  #     time.sleep(0.5)
  # 
  # print('>> OK')
  
  km = KernelManager(kernel_name='python3')
  km.connection_file = debug_file
  km.start_kernel()

  # replace host
  with open(debug_file, 'r') as file:
    data = file.read()
    data = data.replace('127.0.0.1', 'host.docker.internal')

  # write back
  with open(conn_file, 'w') as file:
    file.write(data)
    file.close()

  # start docker
  p2 = Process(target = start_docker, args = (datashare_path,))
  p2.start()

  # wait for shiny to start up
  docker_init = False

  print('>> wait for docker...')

  while docker_init is False:
    try:
      ret_code = urllib.request.urlopen(shiny_url).getcode()

      if ret_code == 200:
        docker_init = True
      else:
        time.sleep(0.5)
    except:
      time.sleep(1)

  print('>> OK')
  webbrowser.open(shiny_url)

  # wait for docker exit
  p2.join()

  # kill jupyter
  p1.terminate()
