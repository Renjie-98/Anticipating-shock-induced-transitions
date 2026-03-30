function output_one = Perturpation_real_M(nnlros, A, perturbation_type, x0)


if perturbation_type == 1 % run node perturbation function
    output_one = node_removal_M(nnlros,A,x0);
elseif perturbation_type == 2 % run link perturbation function
    output_one = link_removal_M(nnlros, A,x0);
else % run weight perturbation function
    output_one = weight_changes_M(A, x0);
end

end 