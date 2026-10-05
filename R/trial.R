# Import identifiers as text to preserve their original representation.
read_trial <- function(file) {
  d <- utils::read.csv(file, check.names=FALSE, colClasses="character", na.strings=c("", "NA"))
  required <- c("studyDbId", "germplasmName", "observationUnitDbId", "rowNumber", "colNumber", "entryType")
  if (!all(required %in% names(d))) stop("Missing columns: ", paste(setdiff(required,names(d)),collapse=", "))
  if (anyDuplicated(names(d))) stop("Duplicate column headers.")
  if (length(unique(d$studyDbId)) != 1 || anyNA(d$studyDbId)) stop("Supply one trial per file.")
  traits <- names(d)[grepl("\\|",names(d),fixed=FALSE)]
  if (!length(traits)) stop("No ontology-labelled phenotype columns found.")
  for (k in traits) {
    x <- suppressWarnings(as.numeric(d[[k]]))
    if (any(!is.na(d[[k]]) & (!is.finite(x) | is.na(x)))) stop("Invalid numeric observations in ", k)
    d[[k]] <- x
  }
  for(k in c("rowNumber","colNumber")) {
    x <- suppressWarnings(as.numeric(d[[k]]))
    if(anyNA(x) || any(!is.finite(x)) || any(x != floor(x))) stop("Invalid field coordinates.")
    d[[k]] <- x
  }
  if(anyNA(d$observationUnitDbId) || anyDuplicated(d$observationUnitDbId)) stop("Observation-unit IDs must be unique and present.")
  if(anyDuplicated(paste(d$rowNumber,d$colNumber))) stop("Multiple plots share field coordinates; separate layouts before mapping.")
  structure(list(data=d, traits=traits, file=basename(file)),class="trial_lens")
}
trial_summary <- function(trial) {
  d <- trial$data
  data.frame(trait=trial$traits, observed=vapply(d[trial$traits],function(x) sum(!is.na(x)),integer(1)),
    missing=vapply(d[trial$traits],function(x) sum(is.na(x)),integer(1)), row.names=NULL)
}
compare_checks <- function(trial, trait=trial$traits[1]) {
  if(!trait %in% trial$traits) stop("Unknown trait.")
  d <- trial$data; x <- d[[trait]]
  checks <- !is.na(d$entryType) & tolower(d$entryType)=="check" & !is.na(x)
  # Balance the baseline across check varieties, rather than weighting by plot count.
  cm <- tapply(x[checks],d$germplasmName[checks],mean)
  baseline <- if(length(cm)) mean(cm) else NA_real_
  groups <- split(seq_len(nrow(d)),d$germplasmName)
  out <- do.call(rbind,lapply(names(groups),function(g) {
    ix<-groups[[g]]; vals<-x[ix]; present<-vals[!is.na(vals)]
    avg<-if(length(present)) mean(present) else NA_real_
    data.frame(genotype=g, entry_type=paste(unique(d$entryType[ix]),collapse="/"),
      observed=length(present), missing=sum(is.na(vals)), mean=avg,
      check_baseline=baseline, difference=avg-baseline,
      percent_difference=if(is.finite(baseline) && baseline!=0) 100*(avg-baseline)/abs(baseline) else NA_real_)
  }))
  rownames(out)<-NULL; out
}
trial_report <- function(trial, file="trialLens-report.html", open=interactive()) {
  template <- system.file("report.html",package="trialLens")
  if(!nzchar(template)) stop("Install trialLens before generating a report.")
  payload <- jsonlite::toJSON(list(data=trial$data, traits=trial$traits, summary=trial_summary(trial),
    comparisons=lapply(trial$traits,function(t) compare_checks(trial,t))), dataframe="rows",auto_unbox=TRUE,na="null",digits=NA)
  payload <- gsub("<", "\\u003c", payload, fixed=TRUE)
  html <- paste(readLines(template,warn=FALSE),collapse="\n")
  parts <- strsplit(html,"__TRIAL_DATA__",fixed=TRUE)[[1]]
  writeLines(paste0(parts[1],payload,parts[2]),file,useBytes=TRUE)
  if(open) utils::browseURL(normalizePath(file))
  invisible(normalizePath(file))
}
