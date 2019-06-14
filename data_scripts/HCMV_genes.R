

hcmv_genes_ncbi<-fread("~/hcmv_genes.txt")

hcmv_genes_db<-db_query("SELECT gene_id, gene_symbol FROM genes WHERE species_id =2")


hcmv_gene_merge<-merge(hcmv_genes_db,hcmv_genes_ncbi,by.x="gene_symbol",by.y="Symbol")%>%
  .[,.(gene_id, 'ncbi_id'=GeneID,
       'gene_name'=description,
       'refseq_ids'=genomic_nucleotide_accession.version,
       'gene_synonyms'=Aliases)]


update_db<-function(ncbi_id, gene_name, refseq_ids, gene_synonyms, gene_id){
db_statement("UPDATE genes 
             SET ncbi_id=?,gene_name=?, refseq_ids=?, gene_synonyms=?, gene_status =1
             WHERE gene_id = ?",
             params=list(ncbi_id, gene_name, refseq_ids, gene_synonyms, gene_id),
             user_db="macrophage_mysql"
             )
}

hcmv_gene_merge[,mapply(update_db,ncbi_id, gene_name, refseq_ids, gene_synonyms, gene_id)]
