
# == title
# Load keyword genesets for a specific species
#
# == param
# -taxon_id The taxon ID. To make it more flexible, you can also provide the Latin name or the normal name of the species.
# -category Category of keywords. There are the following categories: "Biological process", "Cellular component", "Coding sequence diversity", "Developmental stage", "Disease", "Domain", "Ligand", "Molecular function", "Post-translational modification", "Technical term". 
# -as_table If true, the returned value will be a two-column data frame.
#
# == details
# Following are the supported species (with more than 1000 genes annotated):
#
# - "10090": Mus musculus / house mouse
# - "10116": Rattus norvegicus / Norway rat
# - "208964": Pseudomonas aeruginosa PAO1 / strain, g-proteobacteria
# - "224308": Bacillus subtilis subsp. subtilis str. 168 / strain, firmicutes
# - "237561": Candida albicans SC5314 / strain, budding yeasts
# - "243232": Methanocaldococcus jannaschii DSM 2661 / strain, euryarchaeotes
# - "284812": Schizosaccharomyces pombe 972h- / strain, ascomycete fungi
# - "3702": Arabidopsis thaliana / thale cress
# - "39947": Oryza sativa Japonica Group / (Japanese rice), monocots
# - "44689": Dictyostelium discoideum / species, cellular slime molds
# - "559292": Saccharomyces cerevisiae S288C / strain, budding yeasts
# - "6239": Caenorhabditis elegans / species, nematodes
# - "623": Shigella flexneri / species, enterobacteria
# - "7227": Drosophila melanogaster / (fruit fly), species, flies
# - "7955": Danio rerio / (zebrafish), species, bony fishes
# - "83332": Mycobacterium tuberculosis H37Rv / strain, high G+C Gram-positive bacteria
# - "83333": Escherichia coli K-12 / strain, enterobacteria
# - "83334": Escherichia coli O157:H7 / serotype, enterobacteria
# - "8355": Xenopus laevis / (African clawed frog), species, frogs & toads
# - "8364": Xenopus tropicalis / (tropical clawed frog), species, frogs & toads
# - "9031": Gallus gallus / (chicken), species, birds
# - "9601": Pongo abelii / (Sumatran orangutan), species, primates
# - "9606": Homo sapiens / human
# - "9823": Sus scrofa / (pig), species, even-toed ungulates
# - "9913": Bos taurus / cattle
# - "99287": Salmonella enterica subsp. enterica serovar Typhimurium str. LT2 / strain, enterobacteria
#
# == value
# If ``as_table`` is set to ``FALSE``, it returns a list of gene sets where Entrez IDs are the gene IDs.
# If ``as_table`` is set to ``TRUE``, it returns a two-column data frame.
#
# == example
# lt = load_keyword_genesets(9606)
# lt[3:4]
# tb = load_keyword_genesets(9606, as_table = TRUE)
# head(tb)
# # load_keyword_genesets("mouse")
load_keyword_genesets = function(taxon_id = 9606, category = NULL, as_table = FALSE) {

	if(!grepl("^\\d+$", taxon_id)) {
		i = grep(taxon_id, ORGANISM[, 2], ignore.case = TRUE)
		if(length(i) == 1) {
			taxon_id = ORGANISM[i, 1]
		} else {
			i = grep(taxon_id, ORGANISM[, 3], ignore.case = TRUE)
			if(length(i) == 1) {
				taxon_id = ORGANISM[i, 1]
			} else {
				stop("Species '", taxon_id, "' is not supported.")
			}
		}
	}

	f = system.file("extdata", "keywords_anno", paste0("keywords_", taxon_id, "_gene_annotation.rds"), package = "UniProtKeywords")
	if(file.exists(f)) {
		lt = readRDS(f)
	} else {
		stop("Species '", taxon_id, "' is not supported.")
	}

	if(!is.null(category)) {

		if(any(category == "Post-translational modification")) {
			category[category == "Post-translational modification"] = "PTM"
		}

		diff = setdiff(category, ALL_KEYWORDS_CATEGORIES)
		if(length(setdiff(category, ALL_KEYWORDS_CATEGORIES)) == 1) {
			stop("Following value for `category` is not allowed: ", diff)
		} else if(length(setdiff(category, ALL_KEYWORDS_CATEGORIES)) > 1) {
			not_allowed = paste(diff, collapse = ", ")
			stop("Following values for `category` are not allowed: ", not_allowed)
		}

		l = vapply(names(lt), function(nm) {
			any(kw_terms[[nm]]$Category %in% category)
		}, TRUE)
		lt = lt[l]
	}
	lt = lapply(lt, as.character)

	if(as_table) {
		tb = data.frame(keyword = rep(names(lt), times = vapply(lt, length, 0)),
			            gene = unlist(lt))
		rownames(tb) = NULL
		return(tb)
	} else {

		return(lt)
	}
}

ALL_KEYWORDS_CATEGORIES = c("Biological process", "Cellular component", "Coding sequence diversity", 
	                        "Developmental stage", "Disease", "Domain", "Ligand", "Molecular function", 
	                        "Post-translational modification", "PTM", "Technical term")


.onLoad <- function(lib, pkg) {
	data(kw_terms, package = pkg, envir = topenv())
}


ORGANISM = read.table(textConnection(
"10090;Mus musculus;house mouse
10116;Rattus norvegicus;Norway rat
208964;Pseudomonas aeruginosa PAO1;strain, g-proteobacteria
224308;Bacillus subtilis subsp. subtilis str. 168;strain, firmicutes
237561;Candida albicans SC5314;strain, budding yeasts
243232;Methanocaldococcus jannaschii DSM 2661;strain, euryarchaeotes
284812;Schizosaccharomyces pombe 972h-;strain, ascomycete fungi
3702;Arabidopsis thaliana;thale cress
39947;Oryza sativa Japonica Group;(Japanese rice), monocots
44689;Dictyostelium discoideum;species, cellular slime molds
559292;Saccharomyces cerevisiae S288C;strain, budding yeasts
6239;Caenorhabditis elegans;species, nematodes
623;Shigella flexneri;species, enterobacteria
7227;Drosophila melanogaster;(fruit fly), species, flies
7955;Danio rerio;(zebrafish), species, bony fishes
83332;Mycobacterium tuberculosis H37Rv;strain, high G+C Gram-positive bacteria
3333;Escherichia coli K-12;strain, enterobacteria
83334;Escherichia coli O157:H7;serotype, enterobacteria
8355;Xenopus laevis;(African clawed frog), species, frogs & toads
8364;Xenopus tropicalis;(tropical clawed frog), species, frogs & toads
9031;Gallus gallus;(chicken), species, birds
9601;Pongo abelii;(Sumatran orangutan), species, primates
9606;Homo sapiens;human
9823;Sus scrofa;(pig), species, even-toed ungulates
9913;Bos taurus;cattle
99287;Salmonella enterica subsp. enterica serovar Typhimurium str. LT2;strain, enterobacteria
"), sep = ";")

