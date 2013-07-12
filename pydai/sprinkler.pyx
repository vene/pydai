from libcpp.vector cimport vector
from libcpp.map cimport map


cdef extern from "dai/var.h" namespace "dai":
    cdef cppclass Var:
        Var()
        Var(int, int)

cdef extern from "dai/varset.h" namespace "dai":
    cdef cppclass VarSet:
        VarSet()
        VarSet(Var&)
        VarSet(Var&, Var&)
        VarSet& insert(Var)

cdef extern from "dai/factor.h" namespace "dai":
    cdef cppclass TFactor[T]:
        TFactor()
        TFactor(Var&)
        TFactor(VarSet&)
        void set(int, T)
        TFactor[T] marginal(VarSet&, bool)
        TFactor[T]& multiply "operator*=" (TFactor[T]&)
        T get (int)
    
    ctypedef TFactor[double] Factor

cdef extern from "dai/factorgraph.h" namespace "dai":
    cdef cppclass FactorGraph:
        FactorGraph()
        FactorGraph(vector[Factor]&)
        int nrVars()
        int nrFactors()
        Factor& factor(int)


def test():
    cdef Var c = Var(0, 2)
    cdef Var s = Var(1, 2)
    cdef Var r = Var(2, 2)
    cdef Var w = Var(3, 2)

    cdef Factor p_c = Factor(c)
    p_c.set(0, 0.5)
    p_c.set(1, 0.5)

    cdef Factor p_s_given_c = Factor(VarSet(s, c))
    p_s_given_c.set(0, 0.5)
    p_s_given_c.set(1, 0.9)
    p_s_given_c.set(2, 0.5)
    p_s_given_c.set(3, 0.1)

    cdef Factor p_r_given_c = Factor(VarSet(r, c))
    p_r_given_c.set(0, 0.8)
    p_r_given_c.set(1, 0.2)
    p_r_given_c.set(2, 0.2)
    p_r_given_c.set(3, 0.8)
    cdef VarSet srw = VarSet(s, r)
    srw.insert(w)

    cdef Factor p_w_given_s_r = Factor(srw)
    p_w_given_s_r.set(0, 1.0)
    p_w_given_s_r.set(1, 0.1)
    p_w_given_s_r.set(2, 0.1)
    p_w_given_s_r.set(3, 0.01)
    p_w_given_s_r.set(4, 0.0)
    p_w_given_s_r.set(5, 0.9)
    p_w_given_s_r.set(6, 0.9)
    p_w_given_s_r.set(7, 0.99)
    cdef vector[Factor] factors

    factors.push_back(p_c) 
    factors.push_back(p_r_given_c) 
    factors.push_back(p_s_given_c) 
    factors.push_back(p_w_given_s_r) 

    cdef FactorGraph net = FactorGraph(factors)

    print "{} variables, {} factors".format(net.nrVars(), net.nrFactors())
    cdef Factor p
    for i from 0 <= i < net.nrFactors():
        p.multiply(net.factor(i))
    cdef Factor marg = p.marginal(VarSet(w), True)
    denom = marg.get(1)
    cdef VarSet sw = VarSet(s, w)
    cdef VarSet rw = VarSet(r, w)
    print "P(W=1) = {}".format(denom)
    marg = p.marginal(sw, True)
    print "P(S=1 | W=1) = {}".format(marg.get(3) / denom)
    marg = p.marginal(rw, True)
    print "P(R=1 | W=1) = {}".format(marg.get(3) / denom)
