function final_neigh_label = Seed_decision( cen_dep, neigh_dep, seed_dep, seed_lab, neigh_lab, cen_lab, neigh_label, final_neigh_ori )

dep_cen_diff = abs(cen_dep - neigh_dep);
dep_seed_diff = abs(seed_dep - neigh_dep);

Dlab1 =  norm(cen_lab - neigh_lab);
lab_cen_diff = 1-exp( -10 * Dlab1 );%num¡Á1
Dlab2 =  norm(seed_lab - neigh_lab);
lab_seed_diff = 1-exp( -10 * Dlab2 );%num¡Á1

cen_diff = normalize(dep_cen_diff.*lab_cen_diff);
seed_diff = normalize(dep_seed_diff.*lab_seed_diff);

cen_neigh_label = neigh_label(find(cen_diff <= 0.1));
seed_neigh_label = neigh_label(find(seed_diff <= 0.2));
final_neigh_label = setdiff(intersect(cen_neigh_label,seed_neigh_label),final_neigh_ori);

end

