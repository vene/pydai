from .base import Var, VarSet, Factor, FactorGraph


def test():
    c = Var(0, 2)
    s = Var(1, 2)
    r = Var(2, 2)
    w = Var(3, 2)

    p_c = Factor(c)
    p_c[0] = 0.5
    p_c[1] = 0.5

    p_s_given_c = Factor(vs=VarSet([s, c]))
    p_s_given_c[0] = 0.5
    p_s_given_c[1] = 0.9
    p_s_given_c[2] = 0.5
    p_s_given_c[3] = 0.1

    p_r_given_c = Factor(vs=VarSet([r, c]))
    p_r_given_c[0] = 0.8
    p_r_given_c[1] = 0.2
    p_r_given_c[2] = 0.2
    p_r_given_c[3] = 0.8
#    cdef VarSet srw = VarSet(s, r)
#    srw.insert(w)
#
    p_w_given_s_r = Factor(vs=VarSet([s, r, w]))
    p_w_given_s_r[0] = 1.0
    p_w_given_s_r[1] = 0.1
    p_w_given_s_r[2] = 0.1
    p_w_given_s_r[3] = 0.01
    p_w_given_s_r[4] = 0.0
    p_w_given_s_r[5] = 0.9
    p_w_given_s_r[6] = 0.9
    p_w_given_s_r[7] = 0.99

    net = FactorGraph([p_c, p_r_given_c, p_s_given_c, p_w_given_s_r])

    print "{} variables, {} factors".format(net.nr_vars(), net.nr_factors())
    p = net[3]
    print p.marginal(VarSet([w, w]))[3]
    #for f in net:
    #    p *= f
    denom = p.marginal(VarSet([w]))[1]
    print "P(W=1) = {}".format(denom)
    print "P(S=1 | W=1) = {}".format(p.marginal(VarSet([s, w]))[3] / denom)
    print "P(R=1 | W=1) = {}".format(p.marginal(VarSet([r, w]))[3] / denom)
