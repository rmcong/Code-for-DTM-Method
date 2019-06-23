function final_neigh_label = DEPTH_Panduan( cen_dep, neigh_dep, neigh_label, seed_dep, final_neigh_ori )

dep_cen_diff = abs(cen_dep - neigh_dep);
dep_seed_diff = abs(seed_dep - neigh_dep);
cen_neigh_label = neigh_label(find(dep_cen_diff <= 0.1));
seed_neigh_label = neigh_label(find(dep_seed_diff <= 0.2));
final_neigh_label = setdiff(intersect(cen_neigh_label,seed_neigh_label),final_neigh_ori);

end

