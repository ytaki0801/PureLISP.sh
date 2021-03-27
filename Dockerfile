# docker build --tag ytaki0801/plsh .
FROM busybox
ADD https://raw.githubusercontent.com/ytaki0801/PureLISP.sh/main/PureLISP.sh .
CMD ["sh", "PureLISP.sh"]

# docker run --rm -it ytaki0801/plsh
