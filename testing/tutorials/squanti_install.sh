module load perl python minimap2

export PATH=$HOME/anacondaPy37/bin:$PATH
conda -V
#conda update conda

source_dir=/home/sevillas2/git/sevillas2/RBL3/sqanti/
cd $source_dir
git clone https://github.com/ConesaLab/SQANTI3.git

#activate sqanti3
cd SQANTI3
conda env create -f SQANTI3.conda_env.yml
source activate SQANTI3

#install gtfTogenPred
wget http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/gtfToGenePred -P SQANTI3/utilities/
chmod +x SQANTI3/utilities/gtfToGenePred 

#install cupcake (per squanti)
git clone https://github.com/Magdoll/cDNA_Cupcake.git
cd cDNA_Cupcake
python setup.py build
python setup.py install
export PYTHONPATH=$PYTHONPATH:cDNA_Cupcake/sequence/
cd ..

#install cupcake v2
export PATH="/home/anacondaPy37/bin:$PATH"
conda -V
conda create -n anaCogent python=3.7 anaconda
export PATH="/home/anacondaPy37/bin:$PATH"
conda activate anaCogent

#install bx-python
pip install bx-python

#activate new env
source activate anaCogent
git clone https://github.com/Magdoll/cDNA_Cupcake.git
cd cDNA_Cupcake
python setup.py build
python setup.py install