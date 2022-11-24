# Launch jupyter and docker
import os
import platform
import time
import shutil
import IPython
from multiprocessing import Process

# get directories for jupyter files
dir_name = os.path.dirname(__file__)
datashare_path = os.path.join(dir_name, 'datashare')

# get connection files
conn_file = os.path.join(datashare_path, 'connectionFile.json')
debug_file = os.path.join(datashare_path, 'connectionFile.debug.json')

if os.path.exists(datashare_path) is False:
  os.mkdir(datashare_path)

# remove connection file for IPython kernel
if os.path.exists(conn_file):
  os.remove(conn_file)

# start ipython kernel detached
def start_ipython(conn_file):
  print('>> Start IPython')
  
  IPython.start_kernel(argv=[f'-f={conn_file}'])
  
# start ipython kernel detached
def start_docker(datashare_path):
  print('>> Start Docker')
  
  if platform.system() != 'Windows':
    os.system(f'export JUPYTER_LIB_DIR="{datashare_path}" && docker compose up --build')

if __name__ == '__main__':
  # start ipython
  p1 = Process(target = start_ipython, args = (conn_file,))
  p1.start()
  
  # wait until jupyter started and replace for docker
  ipython_init = False
  
  print(">> wait for kernel...")
  
  while ipython_init is False:
    if os.path.exists(conn_file):
      ipython_init = True
    else:
      time.sleep(0.5)
      
  print(">> OK")
  
  # replace host
  shutil.copyfile(conn_file, debug_file)
  
  with open(conn_file, 'r') as file:
    data = file.read()
    data = data.replace('127.0.0.1', 'host.docker.internal')
  
  # write back
  with open(conn_file, 'w') as file:
    file.write(data)
  
  # start docker
  # p2 = Process(target = start_docker, args = (datashare_path,))
  # p2.start()
  
  p1.join()
  # p2.join()
