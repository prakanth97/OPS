from __future__ import annotations

from util import Findable

class Strategy(Findable):
    name: str

    def __str__(self) -> str:
        return self.name

    def __eq__(self, other) -> bool:
        return self.name == other.name if type(other) is type(self) else False

    def __hash__(self) -> int:
        return hash(self.name)

    def matches(self, key: str) -> bool:
        return self.name == key.lower()


class Sequential(Strategy):
    name = "seq"

class GPU_NVVM(Strategy):
    name = "gpu_nvvm"

class OpenMP(Strategy):
    name = "openmp"


Strategy.register(Sequential)
Strategy.register(OpenMP)
Strategy.register(GPU_NVVM)
