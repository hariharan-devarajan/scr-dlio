

import numpy as np
from mpi4py import MPI

comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()
print(f"running test {rank} of {size}")
amode = MPI.MODE_WRONLY|MPI.MODE_CREATE
fh = MPI.File.Open(comm, "./datafile.noncontig", amode)

item_count = 2048
buffer = np.empty(item_count, dtype=np.uint8)
buffer[:] = comm.Get_rank()

offset = comm.Get_rank()*item_count
fh.Write_at_all(offset, buffer)
fh.Close()