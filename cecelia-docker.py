# Launch jupyter and docker
import os
import platform
import IPython
from multiprocessing import Process

# get directories for jupyter files
dir_name = os.path.dirname(__file__)
datashare_path = os.path.join(dir_name, 'datashare')

if os.path.exists(datashare_path) is False:
  os.mkdir(datashare_path)

# start ipython kernel detached
def start_ipython(path):
  print('>> Start IPython')
  
  # get connection files
  conn_file = os.path.join(path, 'connectionFile.json')
  debug_file = os.path.join(path, 'connectionFile.debug.json')
  
  # remove connection file for IPython kernel
  if os.path.exists(conn_file):
    os.remove(conn_file)
    
  IPython.start_kernel(argv=[f'-f={conn_file}'])
  
# start ipython kernel detached
def start_docker(path):
  print('>> Start Docker')
  
  if platform.system() != 'Windows':
    os.system(f'export JUPYTER_LIB_DIR="{path}" && docker compose up --build')
  else:
    pass()

if __name__ == '__main__':
  # start ipython
  p1 = Process(target = start_ipython, args = (datashare_path,))
  p1.start()
  
  # start docker
  p2 = Process(target = start_docker, args = (datashare_path,))
  p2.start()
  
  p1.join()
  p2.join()
