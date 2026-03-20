syms phi real
init=[ 1 0 ]';
sigmax=spinOp(1/2,'x');
sigmay=spinOp(1/2,'y');
sigmaz=spinOp(1/2,'z');

ham=1*sigmax+0*(sigmax^2);
evo=ham.*phi.*1i;
exp_evo=expm(-evo);
final_state=exp_evo*init;
final_pop=(real(final_state)).^2+(imag(final_state)).^2;

simplify(exp_evo);
simplify(final_pop(1))
%%%
syms phi real
init=[ 1 0 0 0 0 0 ]';
sigmax=spinOp(5/2,'x');
sigmay=spinOp(5/2,'y');
sigmaz=spinOp(5/2,'z');

ham=0*sigmax+(sigmax^2);
evo=ham.*phi.*1i;
exp_evo=expm(-evo);
final_state=exp_evo*init;
final_pop=(real(final_state)).^2+(imag(final_state)).^2;

simplify(exp_evo);
simplify(final_pop(1))
%%%
syms phi real
init=[ 1 0 0 0 0 0 ]';
sigmax=spinOp(5/2,'x');
sigmay=spinOp(5/2,'y');
sigmaz=spinOp(5/2,'z');

ham=sigmax+(sigmax^2);
evo=ham.*phi.*1i;
exp_evo=expm(-evo);
final_state=exp_evo*init;
final_pop=(real(final_state)).^2+(imag(final_state)).^2;

simplify(exp_evo);
simplify(final_pop(1))
%%%
syms phi real
init=[ 1 0 0 0 0 0 ]';
sigmax=spinOp(5/2,'x');
sigmay=spinOp(5/2,'y');
sigmaz=spinOp(5/2,'z');

ham=sigmax+2*(sigmax^2);
evo=ham.*phi.*1i;
exp_evo=expm(-evo);
final_state=exp_evo*init;
final_pop=(real(final_state)).^2+(imag(final_state)).^2;

simplify(exp_evo);
simplify(final_pop(1))