from cython.operators import dereference as deref

from libcpp.vector cimport vector
from libcpp.map cimport map
from libcpp cimport bool


cimport classes

cdef class Var:
    cdef classes.Var *thisptr
    cdef bool allocate

    def __cinit__(self, int label=None, int state=None, allocate=True):
        self.allocate = allocate
        if allocate:
            if label is not None and state is not None:
                self.thisptr = new classes.Var(label, state)
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
        (<classes.VarSet> self.thisptr).insert(<classes.Var> v.thisptr)


cdef class Factor:
    cdef classes.Factor *thisptr
    cdef bool allocate

    def __cinit__(self, Var v=None, VarSet vs=None, bool allocate=True):
        self.allocate = allocate
        if allocate:
            if v is not None:
                self.thisptr = new classes.Factor(<classes.Var> v.thisptr)
            elif vs is not None:
                self.thisptr = new classes.Factor(<classes.VarSet> vs.thisptr)
            else:
                self.thisptr = new classes.Factor()

    def __dealloc__(self):
        if self.allocate:
            del self.thisptr

    def __getitem__(self, int i):
        return (<classes.Factor> self.thisptr).get(i)

    def __setitem__(self, int i, double val):
        (<classes.Factor> self.thisptr).set(i, val)

    def __mul__(x, y):
        ret = Factor(allocate=False)
        cdef classes.Factor cret = (<classes.Factor> x.thisptr).multiply(
            <classes.Factor> y.thisptr)
        ret.thisptr = <classes.Factor*> cret
        return ret

    def marginal(self, VarSet vs, bool normed=True):
        ret = Factor(allocate=False)
        cdef classes.Factor cret = self.thisptr.marginal(
            <classes.VarSet> vs.thisptr, normed)
        ret.thisptr = &cret
        return ret

cdef class FactorGraph:
    cdef classes.FactorGraph *thisptr
    cdef bool allocate
    def __cinit__(self, list factors, allocate=True):
        self.allocate = allocate
        if allocate:
            if factors is not None:
                cfactors = [(<object> fact.thisptr) for fact in factors]
                self.thisptr = new classes.FactorGraph(<vector[classes.Factor]> cfactors)
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
        ret.thisptr = &(self.thisptr.factor(i))
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
