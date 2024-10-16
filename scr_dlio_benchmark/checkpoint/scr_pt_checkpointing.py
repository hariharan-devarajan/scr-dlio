"""
   Copyright (c) 2022, UChicago Argonne, LLC
   All Rights Reserved

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
"""
import os
import torch
import logging
from dlio_benchmark.checkpointing.base_checkpointing import BaseCheckpointing
from dftracer.logger import dft_fn as Profile

from dlio_benchmark.common.constants import MODULE_CHECKPOINT
from dlio_benchmark.common.enumerations import CheckpointLocationType
from dlio_benchmark.utils.utility import DLIOMPI
import scr

dlp = Profile(MODULE_CHECKPOINT)


class SCRPyTorchCheckpointing(BaseCheckpointing):
    __instance = None

    @staticmethod
    def get_instance():
        """ Static access method. """
        if SCRPyTorchCheckpointing.__instance is None:
            SCRPyTorchCheckpointing.__instance = SCRPyTorchCheckpointing()
        return SCRPyTorchCheckpointing.__instance

    @dlp.log_init
    def __init__(self):
        super().__init__("pt")
        scr.init()

    @dlp.log
    def get_tensor(self, size):
        return torch.randint(high=1, size=(size,), dtype=torch.int8)

    @dlp.log
    def save_state(self, suffix, state):
        name = self.get_name(suffix)
        scr_name = scr.route_file(name)
        logging.debug(f"SCR checkpointing on file {scr_name} for {name}")
        with open(scr_name, "wb") as f:
            torch.save(state, f)



    @dlp.log
    def checkpoint(self, epoch, step_number):
        with Profile(name=f"checkpoint_start_{epoch}_{step_number}", cat=MODULE_CHECKPOINT, epoch=epoch, step=step_number):
            scr.start_output(f"scr-chk-{epoch}-{step_number}", scr.FLAG_CHECKPOINT)
        valid = True
        try:
            if DLIOMPI.get_instance().rank() == 0:
                logging.debug(f"SCR checkpointing for epoch:{epoch} and step:{step_number}")
            super().checkpoint(epoch, step_number)
        except:
            # failed to write file
            valid = False
        with Profile(name=f"checkpoint_end_{epoch}_{step_number}", cat=MODULE_CHECKPOINT, epoch=epoch, step=step_number) as prof:
            rc = scr.complete_output(valid)
            prof.update(args={"valid": str(valid)})

    @dlp.log
    def finalize(self):
        scr.finalize()
