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

    def __cinit__(self, list variables, bool allocate):
        self.allocate = allocate
        if allocate:
            self.thisptr = new classes.VarSet()

    def __init__(self, list variables, bool allocate):
        for var in variables:
            self.insert(var)

    def __dealloc__(self):
        if self.allocate:
            del self.thisptr

    def insert(self, Var v):
        self.thisptr[0].insert(v.thisptr[0])


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
        return self.thisptr[0].get(i)

    def __setitem__(self, int i, double val):
        self.thisptr[0].set(i, val)

    def __mul__(Factor x, Factor y):
        ret = Factor(allocate=False)
        cdef classes.Factor cret = x.thisptr[0].multiply(y.thisptr[0])
        ret.thisptr = & cret
        return ret

    def marginal(self, VarSet vs, bool normed=True):
        ret = Factor(allocate=False)
        cdef classes.Factor cret = self.thisptr[0].marginal(
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

    cdef int nr_vars(self):
        return self.thisptr.nrVars()

    cdef int nr_factors(self):
        return self.thisptr.nrFactors()

    def __getitem__(self, int i):
        ret = Factor(allocate=False)
        cdef classes.Factor cret = self.thisptr[0].factor(i)
        ret.thisptr = &cret
        return ret

def test():
    c = Var(1, 2)
#    cdef Var c = Var(0, 2)
#    cdef Var s = Var(1, 2)
#    cdef Var r = Var(2, 2)
#    cdef Var w = Var(3, 2)
#
#    cdef Factor p_c = Factor(c)
#    p_c.set(0, 0.5)
#    p_c.set(1, 0.5)
#
#    cdef Factor p_s_given_c = Factor(VarSet(s, c))
#    p_s_given_c.set(0, 0.5)
#    p_s_given_c.set(1, 0.9)
#    p_s_given_c.set(2, 0.5)
#    p_s_given_c.set(3, 0.1)
#
#    cdef Factor p_r_given_c = Factor(VarSet(r, c))
#    p_r_given_c.set(0, 0.8)
#    p_r_given_c.set(1, 0.2)
#    p_r_given_c.set(2, 0.2)
#    p_r_given_c.set(3, 0.8)
#    cdef VarSet srw = VarSet(s, r)
#    srw.insert(w)
#
#    cdef Factor p_w_given_s_r = Factor(srw)
#    p_w_given_s_r.set(0, 1.0)
#    p_w_given_s_r.set(1, 0.1)
#    p_w_given_s_r.set(2, 0.1)
#    p_w_given_s_r.set(3, 0.01)
#    p_w_given_s_r.set(4, 0.0)
#    p_w_given_s_r.set(5, 0.9)
#    p_w_given_s_r.set(6, 0.9)
#    p_w_given_s_r.set(7, 0.99)
#    cdef vector[Factor] factors
#
#    factors.push_back(p_c) 
#    factors.push_back(p_r_given_c) 
#    factors.push_back(p_s_given_c) 
#    factors.push_back(p_w_given_s_r) 
#
#    cdef FactorGraph net = FactorGraph(factors)
#
#    print "{} variables, {} factors".format(net.nrVars(), net.nrFactors())
#    cdef Factor p
#    for i from 0 <= i < net.nrFactors():
#        p.multiply(net.factor(i))
#    cdef Factor marg = p.marginal(VarSet(w), True)
#    denom = marg.get(1)
#    cdef VarSet sw = VarSet(s, w)
#    cdef VarSet rw = VarSet(r, w)
#    print "P(W=1) = {}".format(denom)
#    marg = p.marginal(sw, True)
#    print "P(S=1 | W=1) = {}".format(marg.get(3) / denom)
#    marg = p.marginal(rw, True)
#    print "P(R=1 | W=1) = {}".format(marg.get(3) / denom)
