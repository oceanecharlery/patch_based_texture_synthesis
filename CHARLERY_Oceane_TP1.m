clear;
close all;

# Texture synthesis - Efros-Leung algorithm

# Patch size
n = 25;


# Chargement de l'image texture en double
Ismp = imread('textures_data/text0.png');
Ismp = im2double(Ismp);
[size_x, size_y, size_z] = size(Ismp);
l = n-2; # random patch de dimensions (lxl)

# Copie du patch lxl au centre de l'output I
# Placer le patch de base (20x20) au centre d'une image vide plus grande (64x64)
size_i = 64;
I = zeros(size_i,size_i,3);
x = uint8(size_i/2 - l/2);
x_end = l + x;
I(x:x_end - 1,x:x_end - 1,:) = Ismp(1:l,1:l,:);
A = Ismp(1:l,1:l,:);


# Initialisation : output, tableau de vérification et matrice de comptage
output = zeros(size(I));
imcopy = zeros(size_i,size_i); # Vérifier si un pixel est blanc ou coloré
imcopy(x:x_end - 1,x:x_end - 1) = 1;

# Matrice de comptage (m_sum) : sauvegarde pour chaque pixel son nombre de voisin colorés
m_sum = zeros(size(imcopy));
kernel = ones(n,n);

# Epsilon
e = 0.1;

# Tant que tous les pixels ne sont pas colorés
#while all(imcopy) != 1
for compteur = 1:400
  # Mise à jour de la matrice de comptage
  # Convolution de s_sum avec le kernel pour update le nombre de voisins de chaque pixel
  m_sum = conv2(imcopy, kernel, 'same').* ~imcopy;

  # Récupérer le pixel p qui a le plus de voisins (quantité et coordonnées)
  [_, linearIndexesOfMaxes] = max(m_sum(:));
  [I_col, I_row] = ind2sub(size(m_sum),linearIndexesOfMaxes);

  disp(' ');
  disp(I_col);
  disp(I_row);


  # Patch de centre p dans l'image finale (utiliser uint8 pour opti en fonction de n)
  B = I(I_col-uint8(n/2-1)+1:1:I_col+uint8(n/2-1)+1,I_row-uint8(n/2-1)+1:1:I_row+uint8(n/2-1)+1);

  # Créer un autre patch qui se déplace sur la matrice de vérification (pour calculer la distance)
  BV = imcopy(I_col-uint8(n/2-1)+1:1:I_col+uint8(n/2-1)+1,I_row-uint8(n/2-1)+1:1:I_row+uint8(n/2-1)+1);

  # Calcul des distances
  distance = 10000;
  d = [];
  x = 0;
  y = 0;
  for i = 1:size(Ismp,1)-n
    for j = 1:size(Ismp,2)-n
      A = Ismp(i:i+n-1, j:j+n-1);
      # B - computing the distance of w(p) to all patches of input Ismp
      d = [ d; sum(sum(sum((A-B).^2, 3) .* BV)) ];

      # C - compute smallest distance (wbest)
      if min(d) < distance
        distance = min(d);
        x = i+uint8(n/2-1);
        y = j+uint8(n/2-1);
      end
    end
  end


  # D : liste des patch ayant une distance <= à min(d) * 1 + epsilon
  # Wbest = Ismp(x-uint8(n/2):x+uint8(n/2), y-uint8(n/2-1):y+uint8(n/2));

  W = [];
  W = find(d <= ((1 + e) * distance));

  # E : sélection d'un patch au hasard parmis la liste des meilleurs
  index = randi(size(W,1));
  [W_col, W_row] = ind2sub([size(Ismp,1)-n size(Ismp,2)-n],W(index));
  disp(W_col);
  disp(W_row);

  # F : Mise à jour du pixel p dans l'output
  I(I_col, I_row,:) = Ismp(W_col+n-1,W_row+n-1,:);

  # Mise à jour de la matrice de vérification
  imcopy(I_col, I_row) = 1;
end

# Visualisation de l'output
imshow(I);
