function [output_tstar, output_tminus, output_tplus] = Perturpation_real_M(nnlros, A, perturbation_type, x0)

if perturbation_type == 1
    [output_tstar, output_tminus, output_tplus] = node_removal_M(nnlros, A, x0);
elseif perturbation_type == 2
    [output_tstar, output_tminus, output_tplus] = link_removal_M(nnlros, A, x0);
else
    [output_tstar, output_tminus, output_tplus] = weight_changes_M(A, x0);
end

end