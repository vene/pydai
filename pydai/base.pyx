from libcpp.vector cimport vector
from libcpp.map cimport map
from libcpp cimport bool


cimport classes

cdef class Var:
    cdef classes.Var *thisptr
    cdef bool allocate

    def __cinit__(self, label=None, state=None, allocate=True):
        self.allocate = allocate
        if allocate:
            if label is not None and state is not None:
                self.thisptr = new classes.Var(<int> label, <int> state)
            else:
                self.thisptr = new classes.Var()

    def __dealloc__(self):
        if self.allocate:
            del self.thisptr


cdef class VarSet:
    cdef classes.VarSet *thisptr
    cdef bool allocate

    def __cinit__(self, list variables, bool allocate=True):
        self.allocate = allocate
        if allocate:
            self.thisptr = new classes.VarSet()

    def __init__(self, list variables, bool allocate=True):
        for var in variables:
            self.insert(var)

    def __dealloc__(self):
        if self.allocate:
            del self.thisptr

    def insert(self, Var v):
        self.thisptr.insert(v.thisptr[0])


cdef class Factor:
    cdef classes.Factor *thisptr
    cdef bool allocate

    def __cinit__(self, Var v=None, VarSet vs=None, bool allocate=True):
        self.allocate = allocate
        if allocate:
            if v is not None:
                self.thisptr = new classes.Factor(v.thisptr[0])
            elif vs is not None:
                self.thisptr = new classes.Factor(vs.thisptr[0])
            else:
                self.thisptr = new classes.Factor()

    def __dealloc__(self):
        if self.allocate:
            del self.thisptr

    def __getitem__(self, int i):
        return self.thisptr.get(i)

    def __setitem__(self, int i, double val):
        self.thisptr.set(i, val)

    def __mul__(Factor x, Factor y):
        ret = Factor(allocate=False)
        cdef classes.Factor cret = x.thisptr.multiply(y.thisptr[0])
        ret.thisptr = & cret
        return ret

    def marginal(self, VarSet vs, bool normed=True):
        ret = Factor(allocate=False)
        cdef classes.Factor cret = self.thisptr.marginal(
            vs.thisptr[0], normed)
        ret.thisptr = &cret
        return ret

cdef class FactorGraph:
    cdef classes.FactorGraph *thisptr
    cdef bool allocate
    def __cinit__(self, list factors, bool allocate=True):
        self.allocate = allocate
        cdef vector[classes.Factor] cfactors
        if allocate:
            if factors is not None:
                for fact in factors:
                    cfactors.push_back((<Factor> fact).thisptr[0])
                self.thisptr = new classes.FactorGraph(cfactors)
            else:
                self.thisptr = new classes.FactorGraph()

    def __dealloc__(self):
        if self.allocate:
            del self.thisptr

    cpdef int nr_vars(self):
        return self.thisptr.nrVars()

    cpdef int nr_factors(self):
        return self.thisptr.nrFactors()

    def __getitem__(self, int i):
        ret = Factor(allocate=False)
        cdef classes.Factor cret = self.thisptr.factor(i)
        ret.thisptr = &cret
        return ret
