function mu = meanShape(S)

mu = [mean(S(1:3:end,:),1);mean(S(2:3:end,:),1);mean(S(3:3:end,:),1)];