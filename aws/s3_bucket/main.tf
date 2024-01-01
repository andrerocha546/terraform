resource "aws_s3_bucket" "static_site_bucket" {
    bucket = "static-site-${var.bucket_name}"
    acl    = "private"

    website {
        index_document = "index.html"
        error_document = "error.html"
    }

    tags = {
        Bucket = "Bucket Tag"
        Environment = "Environment Tag"
    }

}

# alterando configurações de bloqueios de acesso publico
resource "aws_s3_bucket_public_access_block" "static_site_bucket" {
    bucket = aws_s3_bucket.static_site_bucket.id

    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "static_site_bucket" {
    bucket = aws_s3_bucket.static_site_bucket.id
    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}

# anexando politica de acesso publico
resource "aws_s3_bucket_acl" "static_site_bucket" {

    depends_on = [
        aws_s3_bucket_public_access_block.static_site_bucket,
        aws_s3_bucket_ownership_controls.static_site_bucket,
    ]
    bucket = aws_s3_bucket.static_site_bucket.id


    acl    = "public-read" 
}